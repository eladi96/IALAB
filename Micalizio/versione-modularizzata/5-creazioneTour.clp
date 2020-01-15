;************************
; COSTRUZIONE TOUR
;
; In questo modulo sono contenute le regole di costruzione del tour. La creazione
; del tour si basa principalmente sulla distanza tra le città. Una volta creati
; tutti i tour possibili, essi vengono valutati in base alle certezze delle città
; che li compongono e degli alberghi scelti per alloggiare. Inoltre sono presenti
; regole per rimuovere tour simili tra loro (per esempio con le stesse città ma in
; diverso ordine), per il calcolo del costo complessivo del tour e per
; la divisione delle notti da trascorrere nelle varie località.
;***********************
(defmodule TOUR (import MAIN ?ALL)
                (import DOMINIO ?ALL)
                (export ?ALL))

; template del tour
(deftemplate TOUR::tour
  (multislot listaCitta)
  (multislot listaAlberghi)
  (multislot listaStelle)
  (multislot listaCosti)
  (multislot listaNotti)
  (slot nottiCompilate (default FALSE))
  (slot costoTour (default 0))
  (slot certezza (type FLOAT)))

; template per la distanza tra due città
(deftemplate TOUR::distanza
  (slot partenza)
  (slot arrivo)
  (slot valore)
)

; regola per calcolare la distanza tra due città
(defrule TOUR::distanza-citta
  (localita (nome ?nome1) (cordN ?n1) (cordE ?e1))
  (localita (nome ?nome2) (cordN ?n2) (cordE ?e2))
  (test (neq ?nome1 ?nome2))
  =>
  (assert (distanza (partenza ?nome1) (arrivo ?nome2) (valore (calcola-distanza ?n1 ?n2 ?e1 ?e2))))
)

; regola per costruire tour da una tappa
; un tour non viene creato se:
;   - l'albergo non ha un numero sufficiente di camere per ospitare tutte le persone che partecipano al tour
(defrule TOUR::citta-di-partenza
  (attributo (nome cittaValutata) (valore ?citta) (certezza ?certezzaCitta))
  (attributo (nome numPersone) (valore ?persone))
  (attributo (nome numGiorni) (valore ?giorni))
  (albergo (nome ?nomeAlbergo)
           (localita ?citta)
           (stelle ?stelle)
           (costoNotte ?costoNotte)
           (camereLibere ?n&:(>= ?n (/ (+ ?persone (mod ?persone 2)) 2))))
  (attributo (nome albergoValutato) (valore ?nomeAlbergo) (certezza ?certezzaAlbergo))
  =>
  (bind ?certezzaTappa (/ (+ ?certezzaCitta ?certezzaAlbergo) 2))
  (bind ?coefficienteTour (/ 1 (/ (+ ?giorni (mod ?giorni 2)) 2)))
  (assert (tour (listaCitta ?citta)
                (listaAlberghi ?nomeAlbergo)
                (listaStelle ?stelle)
                (listaCosti ?costoNotte)
                (certezza (* ?coefficienteTour ?certezzaTappa))))
)

; regola per costruire tour da due o più tappe
; un tour non viene creato se:
;   - l'albergo non ha un numero sufficiente di camere per ospitare tutte le persone che partecipano al tour
;   - la distanza tra due città è superiore a 100 km
;   - la città è stata già inserita precentemente nel tour
;   - il numero di tappe nel tour non deve essere maggiore del numero dei giorni/2
(defrule TOUR::citta-successiva
  ?t <- (tour (listaCitta $?cittaPrec ?cittaCorr)
              (listaAlberghi $?alberghiPrec ?albergoCorr)
              (listaStelle $?stellePrec ?stelleCorr)
              (listaCosti $?costiPrec ?costoCorr)
              (certezza ?certezzaTour))
  (attributo (nome numGiorni) (valore ?giorni))
  (test (< (+ 1 (length$ ?cittaPrec)) (/ ?giorni 2)))

  (attributo (nome cittaValutata) (valore ?cittaSucc) (certezza ?certezzaCittaSucc))
  (distanza (partenza ?cittaCorr) (arrivo ?cittaSucc) (valore ?distanza&:(< ?distanza 100.0)))
  (test (not (member$ ?cittaSucc ?cittaPrec)))

  (attributo (nome numPersone) (valore ?persone))
  (albergo (nome ?albergoSucc)
           (localita ?cittaSucc)
           (stelle ?stelleSucc)
           (costoNotte ?costoSucc)
           (camereLibere ?n&:(>= ?n (/ (+ ?persone (mod ?persone 2)) 2))))
  (attributo (nome albergoValutato) (valore ?albergoSucc) (certezza ?certezzaAlbergoSucc))

  =>
  (bind ?certezzaTappaSucc (/ (+ ?certezzaCittaSucc ?certezzaAlbergoSucc) 2))
  (bind ?numCitta (+ 2 (length$ ?cittaPrec)))
  (bind ?coefficienteTour (/ ?numCitta (/ (+ ?giorni (mod ?giorni 2)) 2)))
  (assert (tour (listaCitta ?cittaPrec ?cittaCorr ?cittaSucc)
                (listaAlberghi ?alberghiPrec ?albergoCorr ?albergoSucc)
                (listaStelle ?stellePrec ?stelleCorr ?stelleSucc)
                (listaCosti ?costiPrec ?costoCorr ?costoSucc)
                (certezza (* ?coefficienteTour (combina-certezze ?certezzaTour ?certezzaTappaSucc)))

)))

; rimuove dalla KB il tour con certezza minore che contiene la maggior parte delle città uguali ad un altro tour
; la regola controlla:
; che la prima metà +1 della lista delle città del secondo tour sia contenuta nella lista delle città del primo tour
; che la seconda metà +1 della lista delle città del secondo tour sia contenuta nella lista delle città del primo tour
(defrule TOUR::rimuovi-tour-ridondanti
  (declare (salience 3))
  ?t1 <- (tour (listaCitta $?listaCitta1) (certezza ?certezza1))
  ?t2 <- (tour (listaCitta $?listaCitta2) (certezza ?certezza2&:(<= ?certezza2 ?certezza1)))
  (test (neq ?t1 ?t2))
  (test (eq (length$ ?listaCitta1) (length$ ?listaCitta2)))
  (test (or (subsetp (subseq$ ?listaCitta2 1 (+ 1 (div (length$ ?listaCitta2) 2))) ?listaCitta1)
            (subsetp (subseq$ ?listaCitta2 (+ 1 (div (length$ ?listaCitta2) 2)) (length$ ?listaCitta2)) ?listaCitta1)))
  =>
  (retract ?t2)
)

; assegna il numero di notti da trascorrere nei vari alberghi richiamando l'omonima funzione
(defrule TOUR::spartisci-notti
  (declare (salience 2))
  ?tour <- (tour (listaCitta $?citta)
                 (listaAlberghi $?alberghi)
                 (listaStelle $?stelle)
                 (listaCosti $?costi)
                 (nottiCompilate FALSE)
                 (certezza ?certezza))
  (attributo (nome numGiorni) (valore ?giorni))
  =>
  (bind ?notti (- ?giorni 1))
  (bind ?nottiPerLocalita (div ?notti (length$ ?citta))
  (bind ?nottiAvanzate (mod ?notti (length$ ?citta))))
  (modify ?tour (listaNotti (spartisci-notti (length$ ?citta) ?nottiPerLocalita ?nottiAvanzate ?costi))
                (nottiCompilate TRUE))
)

; per calcolare il costo complessivo del tour somma i costi delle notti dei vari alberghi
(defrule TOUR::calcola-costo-complessivo
  (declare (salience 1))
  ?tour <- (tour (listaCosti $?costi) (listaNotti $?notti) (nottiCompilate TRUE) (costoTour 0))
  (attributo (nome numPersone) (valore ?persone))
  =>
  (modify ?tour (costoTour (calcola-costo-tour ?costi ?persone ?notti)))
)

; se l'utente ha inserito una preferenza sulla regione da evitare,
; questa regola rimuove tutti i tour che contengono città della regione specificata
(defrule TOUR::rimuovi-tour-regioneDaEvitare
  (declare (salience 3))
  ?t <- (tour (listaCitta $?listaCitta))
  (attributo (nome regioneDaEvitare) (valore ?regione))
  (localita (nome ?citta) (regione ?regione))
  =>
  (if (member$ ?citta ?listaCitta) then
      (retract ?t))
)
