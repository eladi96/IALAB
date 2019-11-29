;************************
; COSTRUZIONE TOUR
;***********************
(defmodule TOUR (import MAIN ?ALL)
                (import DOMANDE ?ALL)
                (import DOMANDEPRINCIPALI ?ALL)
                (import DOMINIO ?ALL)
                (import REGOLE ?ALL)
                (import PUNTEGGIO ?ALL) (export ?ALL))

(deftemplate TOUR::tour
  (multislot listaCitta)
  (multislot listaAlberghi)
  (multislot listaStelle)
  (multislot listaCosti)
  (multislot listaNotti)
  (slot nottiCompilate (default FALSE))
  (slot costoTour (default 0))
  (slot certezza (type FLOAT)))

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

(defrule TOUR::citta-successiva
  ; risolvere problema: casulità degli hotel (nella traccia "favoreggiamento")
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

;(defrule TOUR::rimuovi-permutazioni-tour
;  (declare (salience 4))
;  ?t1 <- (tour (listaCitta $?listaCitta1) (listaAlberghi $?listaAlberghi1))
;  ?t2 <- (tour (listaCitta $?listaCitta2) (listaAlberghi $?listaAlberghi2))
;  ;(test (neq ?t1 ?t2))
;  (test (eq (length$ ?listaCitta1) (length$ ?listaCitta2)))
;  (test (neq ?listaCitta1 ?listaCitta2))
;  (test (neq ?listaAlberghi1 ?listaAlberghi2))
;  (test (subsetp ?listaCitta1 ?listaCitta2))
;  =>
;  (retract ?t2)
;)

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

(defrule TOUR::calcola-costo-complessivo
  (declare (salience 1))
  ?tour <- (tour (listaCosti $?costi) (listaNotti $?notti) (nottiCompilate TRUE) (costoTour 0))
  (attributo (nome numPersone) (valore ?persone))
  =>
  (modify ?tour (costoTour (calcola-costo-tour ?costi ?persone ?notti)))
)

(defrule TOUR::rimuovi-tour-regioneDaEvitare
  (declare (salience 3))
  ?t <- (tour (listaCitta $?listaCitta))
  (attributo (nome regioneDaEvitare) (valore ?regione))
  (localita (nome ?citta) (regione ?regione))
  =>
  (if (member$ ?citta ?listaCitta) then
      (retract ?t))
)
