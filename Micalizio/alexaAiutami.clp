;;*************************
;; MODULO MAIN
;;*************************
(defmodule MAIN (export ?ALL))

;; Template degli attributi che useremo per calcolare la soluzione
(deftemplate MAIN::attributo
  (slot nome)
  (slot valore)
  (slot certezza (default 0.0)))

;; Regola che da inizio all'esecuzione
(defrule MAIN::start
  (declare (salience 10000))
  =>
  (set-fact-duplication TRUE)
  (assert (soluzioni 0))
  (focus DOMINIO
         DOMANDE
         DOMANDEPRINCIPALI
         REGOLE
         RICERCA
         TOUR
         STAMPA))

; funzione per chiedere le domande (MAIN è il modulo)
; La domanda viene chiesta ripetutamente finchè non riceve una risposta corretta
; che sarà un numero positivo nel caso in cui il multislot "risposteValide" contenga
; l'elemento interoPositivo, o una risposta valida tra quelle elencate.
; ?risposta è il valore di ritorno
(deffunction MAIN::chiedi-domanda (?domanda ?risposteValide)
   (printout t ?domanda)
   (bind ?risposta (read))
   (if (lexemep ?risposta) then (bind ?risposta (lowcase ?risposta)))

   (if (member interoPositivo ?risposteValide) then
       (while (not (integerp ?risposta)) do
          (printout t ?domanda)
          (printout t "Inserire un numero positivo")
          (bind ?risposta (read)))
       (while (not (> ?risposta 0)) do
          (printout t ?domanda)
          (printout t "Inserire un numero positivo")
          (bind ?risposta (read))))

   (if (not(member interoPositivo ?risposteValide)) then
       (while (not (member ?risposta ?risposteValide)) do
       (printout t ?domanda)
       (printout t "Inserire una risposta valida.")
       (bind ?risposta (read))
       (if (lexemep ?risposta) then (bind ?risposta (lowcase ?risposta)))))

   ?risposta)

(deffunction MAIN::combina-certezze(?c1 ?c2)
  (bind ?nuovaCertezza 0)
  (bind ?c1 (/ ?c1 100))
  (bind ?c2 (/ ?c2 100))
  (if (and (> ?c1 0) (> ?c2 0)) then
      (bind ?nuovaCertezza (* 100 (- (+ ?c1 ?c2) (* ?c1 ?c2)))))
  (if (and (< ?c1 0) (< ?c2 0)) then
      (bind ?nuovaCertezza (* 100 (+ (+ ?c1 ?c2) (* ?c1 ?c2)))))
  (if (<= (* ?c1 ?c2) 0) then
      (bind ?nuovaCertezza (* 100 (/ (+ ?c1 ?c2) (- 1.01 (min (abs ?c1) (abs ?c2)))))))
  ?nuovaCertezza
)

(deffunction MAIN::controlla-certezza(?c)
  (if (> ?c 100) then (bind ?c 100))
  (if (< ?c -100) then (bind ?c -100))
  ?c
)

(deffunction MAIN::calcola-distanza(?n1 ?n2 ?e1 ?e2)
  (bind ?s1 (sin (deg-rad (- 90 ?n1))))
  (bind ?s2 (sin (deg-rad (- 90 ?n2))))
  (bind ?c1 (cos (deg-rad (- 90 ?n1))))
  (bind ?c2 (cos (deg-rad (- 90 ?n2))))
  (bind ?FI (cos (deg-rad (abs (- ?e1 ?e2))))) ; angolo tra i due punti con vertice nel centro della terra
  (bind ?dist (* 6372.7955 (acos (+ (* ?c1 ?c2) (* ?FI ?s1 ?s2)))))
  ?dist
)

(deffunction MAIN::stampa-tour(?numeroTour ?listaCitta ?listaAlberghi ?listaStelle ?listaCosti ?listaNotti ?certezza ?costoComplessivo)
  (bind ?i 1)
  (format t "%nTOUR %-2d - PUNTEGGIO: %-3.2f - COSTO TOT.: %-7.2f%n%n" ?numeroTour ?certezza ?costoComplessivo)
  (format t "          CITTA                    ALBERGO          STELLE    COSTO NOTTE      NOTTI%n" )
  (while (<= ?i (length$ ?listaCitta)) do
    (bind ?citta (nth$ ?i ?listaCitta))
    (bind ?albergo (nth$ ?i ?listaAlberghi))
    (bind ?stelle (nth$ ?i ?listaStelle))
    (bind ?costo (nth$ ?i ?listaCosti))
    (bind ?notti (nth$ ?i ?listaNotti))
    (format t  "Tappa %-2d: %-25s%-20s%-10g%-15.2f%-10d%n" ?i ?citta ?albergo ?stelle ?costo ?notti)
    (bind ?i (+ 1 ?i))
  )
)

(deffunction MAIN::punteggio-stelle(?stelleUtente ?stelleAlbergo ?certezza)
  (if (neq ?stelleUtente no) then
    (bind ?certezza (* ?certezza (- 1 (/ (abs (- ?stelleUtente ?stelleAlbergo)) 3))))
  )
  ?certezza
)

(deffunction MAIN::spartisci-notti(?numLocalita ?nottiPerLocalita ?nottiAvanzate ?costoNotte)
  (bind ?listaNotti (create$ ))
  (bind ?i 1)
  (while (<= ?i ?numLocalita) do
    (bind ?listaNotti (insert$ ?listaNotti ?i ?nottiPerLocalita))
    (if (> ?nottiAvanzate 0) then
      (bind ?nottiCorrente (nth$ ?i ?listaNotti))
      (bind ?listaNotti (replace$ ?listaNotti ?i ?i (+ ?nottiCorrente 1)))
      (bind ?nottiAvanzate (- ?nottiAvanzate 1))
    )
    (bind ?i (+ 1 ?i))
  )

  (bind ?i 1)
  (while (< ?i ?numLocalita) do
    (bind ?j (+ ?i 1))
    (while (<= ?j ?numLocalita) do
      (if (and (> (nth$ ?i ?costoNotte) (nth$ ?j ?costoNotte))
               (> (nth$ ?i ?listaNotti) (nth$ ?j ?listaNotti))
          ) then
        (bind ?temp (nth$ ?i ?listaNotti))
        (bind ?listaNotti (replace$ ?listaNotti ?i ?i (nth$ ?j ?listaNotti)))
        (bind ?listaNotti (replace$ ?listaNotti ?j ?j ?temp))
      )
      (bind ?j (+ 1 ?j))
    )
    (bind ?i (+ 1 ?i))
  )

  ?listaNotti
)

(deffunction MAIN::calcola-costo-tour(?costi ?persone ?notti)
  (bind ?costoComplessivo 0)
  (bind ?i 1)
  (while (<= ?i (length$ ?costi)) do
    (bind ?costoComplessivo (+ ?costoComplessivo (* (nth$ ?i ?notti) (nth$ ?i ?costi) (+ (div ?persone 2) (mod ?persone 2)))))
    (bind ?i (+ ?i 1))
  )
  ?costoComplessivo
)

;****************************
; MODULO DOMANDE
;****************************
(defmodule DOMANDE (import MAIN ?ALL) (export ?ALL))

; Template delle domande
(deftemplate DOMANDE::templateDomanda
  ; attributo è la variabile che compiliamo con la risposta
  (slot attributo (default ?NONE))
  (slot domanda (default ?NONE))
  (multislot risposteValide (default ?NONE))
  (slot giaChiesta (default FALSE))
  (multislot precursore (default ?DERIVE)))

; Regola che fa avviare la richiesta delle domande. Esse saranno chieste solo se
; il valore giaChiesta valga FALSE, e diventerà TRUE una volta che la domanda sicilia
; stata chiesta.
(defrule DOMANDE::domanda-con-precursore
   ?f <- (templateDomanda (giaChiesta FALSE)
                   (domanda ?domanda)
                   (attributo ?attributo)
                   (risposteValide $?risposteValide)
                   (precursore ?precursore is ?rispostaPrecursore))
  (attributo (nome ?precursore) (valore ?rispostaPrecursore))
   =>
   (modify ?f (giaChiesta TRUE))
   (assert (attributo (nome ?attributo)
                      (valore (chiedi-domanda ?domanda ?risposteValide)))))

(defrule DOMANDE::domanda-senza-precursore
   ?f <- (templateDomanda (giaChiesta FALSE)
                   (domanda ?domanda)
                   (attributo ?attributo)
                   (risposteValide $?risposteValide)
                   (precursore))
   =>
   (modify ?f (giaChiesta TRUE))
   (assert (attributo (nome ?attributo)
                      (valore (chiedi-domanda ?domanda ?risposteValide)))))

;******************************
; DOMANDE PRINCIPALI
;******************************
(defmodule DOMANDEPRINCIPALI (import MAIN ?ALL) (import DOMANDE ?ALL) (export ?ALL))

(deffacts DOMANDEPRINCIPALI::elencoDomandePrincipali

  (templateDomanda (attributo numStelle)
                   (domanda "Hai preferenze sul numero di stelle degli alberghi?")
                   (risposteValide 1 2 3 4 no))
  ; Se non chiediamo i giorni all'inizio, proponiamo una soluzione che abbia un numero numLuoghi pari a numGiorni / 2
  (templateDomanda (attributo budget)
                   (domanda "A quanto ammonta il tuo budget?")
                   (risposteValide interoPositivo))
  (templateDomanda (attributo numPersone)
                   (domanda "Quante persone parteciperanno?")
                   (risposteValide interoPositivo))
  (templateDomanda (attributo numGiorni)
                   (domanda "Quanti giorni deve durare il viaggio? Minimo due.")
                   (risposteValide interoPositivo))
  (templateDomanda (attributo tradizione_avventura)
                   (domanda "Preferisci conoscere le TRADIZIONI del posto o vivere esperienze piu' AVVENTUROSE?")
                   (risposteValide tradizioni avventurose indifferente)
                   (precursore scarpe_costume is scarpe))
  (templateDomanda (attributo spiaggia_spa)
                   (domanda "Preferisci andare in SPIAGGIA o in una SPA?")
                   (risposteValide spiaggia spa indifferente)
                   (precursore scarpe_costume is costume))
  (templateDomanda (attributo scarpe_costume)
                   (domanda "In valigia non deve mancare... SCARPE comode o COSTUME da bagno?")
                   (risposteValide scarpe costume))
  )

;******************************
; REGOLE
;******************************
(defmodule REGOLE (import MAIN ?ALL)
                  (import DOMANDE ?ALL)
                  (import DOMANDEPRINCIPALI ?ALL)
                  (export ?ALL))

(deftemplate REGOLE::regola
  (multislot if)
  (multislot then))

(defrule REGOLE::cancella-and-in-conseguente
  ?f <- (regola (then and $?rest))
  =>
  (modify ?f (then ?rest)))

(defrule REGOLE::leggi-conseguente
  ?d <- (regola (if ?attributoDomanda is ?valoreRisposta)
                (then ?attributoSoluzione is ?valore with certezza ?certezza $?rest))
  (attributo (nome ?attributoDomanda) (valore ?valoreRisposta))
  =>
  (modify ?d (then ?rest))
  (assert (attributo (nome ?attributoSoluzione) (valore ?valore) (certezza ?certezza)))
)

(defrule REGOLE::combina-certezze
  (declare (salience 100)
           (auto-focus TRUE))
  ?attr1 <- (attributo (nome ?n) (valore ?v) (certezza ?c1))
  ?attr2 <- (attributo (nome ?n) (valore ?v) (certezza ?c2))
  (test (neq ?attr1 ?attr2))
  =>
  (retract ?attr1)
  (modify ?attr2 (certezza (combina-certezze ?c1 ?c2))))


(deffacts REGOLE::regole-tour
  (regola (if scarpe_costume is scarpe)
          (then montano is 5 with certezza 70 and
                montano is 4 with certezza 50 and
                montano is 3 with certezza 30 and
                montano is 2 with certezza 10 and
                montano is 1 with certezza 0 and
                montano is 0 with certezza -70 and

                naturalistico is 5 with certezza 70 and
                naturalistico is 4 with certezza 50 and
                naturalistico is 3 with certezza 30 and
                naturalistico is 2 with certezza 10 and
                naturalistico is 1 with certezza 0 and
                naturalistico is 0 with certezza -70 and

                sportivo is 5 with certezza 70 and
                sportivo is 4 with certezza 50 and
                sportivo is 3 with certezza 30 and
                sportivo is 2 with certezza 10 and
                sportivo is 1 with certezza 0 and
                sportivo is 0 with certezza -70 and

                culturale is 5 with certezza 70 and
                culturale is 4 with certezza 50 and
                culturale is 3 with certezza 30 and
                culturale is 2 with certezza 10 and
                culturale is 1 with certezza 0 and
                culturale is 0 with certezza -70 and

                ;negativi
                balneare is 5 with certezza -70 and
                balneare is 4 with certezza -50 and
                balneare is 3 with certezza -30 and
                balneare is 2 with certezza -10 and
                balneare is 1 with certezza 0 and
                balneare is 0 with certezza 50 and

                lacustre is 5 with certezza -70 and
                lacustre is 4 with certezza -50 and
                lacustre is 3 with certezza -30 and
                lacustre is 2 with certezza -10 and
                lacustre is 1 with certezza 0 and
                lacustre is 0 with certezza 50 and

                termale is 5 with certezza -70 and
                termale is 4 with certezza -50 and
                termale is 3 with certezza -30 and
                termale is 2 with certezza -10 and
                termale is 1 with certezza 0 and
                termale is 0 with certezza 50 and))

  (regola (if scarpe_costume is costume)
          (then balneare is 5 with certezza 70 and
                balneare is 4 with certezza 50 and
                balneare is 3 with certezza 30 and
                balneare is 2 with certezza 10 and
                balneare is 1 with certezza 0 and
                balneare is 0 with certezza -70 and

                termale is 5 with certezza 70 and
                termale is 4 with certezza 50 and
                termale is 3 with certezza 30 and
                termale is 2 with certezza 10 and
                termale is 1 with certezza 0 and
                termale is 0 with certezza -70 and

                lacustre is 5 with certezza 70 and
                lacustre is 4 with certezza 50 and
                lacustre is 3 with certezza 30 and
                lacustre is 2 with certezza 10 and
                lacustre is 1 with certezza 0 and
                lacustre is 0 with certezza -70 and

                sportivo is 5 with certezza 50 and
                sportivo is 4 with certezza 40 and
                sportivo is 3 with certezza 30 and
                sportivo is 2 with certezza 20 and
                sportivo is 1 with certezza 10 and
                sportivo is 0 with certezza 0 and

                ;negativi

                montano is 5 with certezza -70 and
                montano is 4 with certezza -50 and
                montano is 3 with certezza -30 and
                montano is 2 with certezza -10 and
                montano is 1 with certezza 0 and
                montano is 0 with certezza 70 and))

  (regola (if spiaggia_spa is spiaggia)
          (then balneare is 5 with certezza 80 and
                balneare is 4 with certezza 60 and
                balneare is 3 with certezza 40 and
                balneare is 2 with certezza 20 and
                balneare is 1 with certezza 0 and
                balneare is 0 with certezza -80 and

                ;negativi
                termale is 5 with certezza -80 and
                termale is 4 with certezza -60 and
                termale is 3 with certezza -40 and
                termale is 2 with certezza -20 and
                termale is 1 with certezza 0 and
                termale is 0 with certezza 80 and))

  (regola (if spiaggia_spa is spa)
          (then termale is 5 with certezza 80 and
                termale is 4 with certezza 60 and
                termale is 3 with certezza 40 and
                termale is 2 with certezza 20 and
                termale is 1 with certezza 0 and
                termale is 0 with certezza -80 and

                ;negativi
                balneare is 5 with certezza -80 and
                balneare is 4 with certezza -60 and
                balneare is 3 with certezza -40 and
                balneare is 2 with certezza -20 and
                balneare is 1 with certezza 0 and
                balneare is 0 with certezza 80 and

                sportivo is 5 with certezza -70 and
                sportivo is 4 with certezza -50 and
                sportivo is 3 with certezza -30 and
                sportivo is 2 with certezza -10 and
                sportivo is 1 with certezza 0 and
                sportivo is 0 with certezza 70 and))

(regola (if tradizione_avventura is tradizioni)
        (then enogastronomico is 5 with certezza 80 and
              enogastronomico is 4 with certezza 60 and
              enogastronomico is 3 with certezza 40 and
              enogastronomico is 2 with certezza 20 and
              enogastronomico is 1 with certezza 0 and
              enogastronomico is 0 with certezza -80 and

              culturale is 5 with certezza 80 and
              culturale is 4 with certezza 60 and
              culturale is 3 with certezza 40 and
              culturale is 2 with certezza 20 and
              culturale is 1 with certezza 0 and
              culturale is 0 with certezza -80 and

              religioso is 5 with certezza 80 and
              religioso is 4 with certezza 60 and
              religioso is 3 with certezza 40 and
              religioso is 2 with certezza 20 and
              religioso is 1 with certezza 0 and
              religioso is 0 with certezza -80 and

              ; negativi
              sportivo is 5 with certezza -60 and
              sportivo is 4 with certezza -40 and
              sportivo is 3 with certezza -30 and
              sportivo is 2 with certezza -20 and
              sportivo is 1 with certezza 0 and
              sportivo is 0 with certezza 60 and

              naturalistico is 5 with certezza -60 and
              naturalistico is 4 with certezza -40 and
              naturalistico is 3 with certezza -30  and
              naturalistico is 2 with certezza -20 and
              naturalistico is 1 with certezza 0 and
              naturalistico is 0 with certezza 60 ))

(regola (if tradizione_avventura is avventurose)
        (then naturalistico is 5 with certezza 80  and
              naturalistico is 4 with certezza 60  and
              naturalistico is 3 with certezza 40  and
              naturalistico is 2 with certezza 20 and
              naturalistico is 1 with certezza 0 and
              naturalistico is 0 with certezza -80 and

              sportivo is 5 with certezza 80 and
              sportivo is 4 with certezza 60 and
              sportivo is 3 with certezza 40 and
              sportivo is 2 with certezza 20 and
              sportivo is 1 with certezza 0 and
              sportivo is 0 with certezza -80 and

              ; negativi
              religioso is 5 with certezza -60  and
              religioso is 4 with certezza -40  and
              religioso is 3 with certezza -30  and
              religioso is 2 with certezza -20 and
              religioso is 1 with certezza 0 and
              religioso is 0 with certezza 60 and

              enogastronomico is 5 with certezza -60 and
              enogastronomico is 4 with certezza -40 and
              enogastronomico is 3 with certezza -30 and
              enogastronomico is 2 with certezza -20 and
              enogastronomico is 1 with certezza 0 and
              enogastronomico is 0 with certezza 60 and

              culturale is 5 with certezza -60 and
              culturale is 4 with certezza -40 and
              culturale is 3 with certezza -30 and
              culturale is 2 with certezza -20 and
              culturale is 1 with certezza 0 and
              culturale is 0 with certezza 60 ))
)


;***********************
; MODULO RICERCA
;***********************
(defmodule RICERCA (import MAIN ?ALL)
                   (import DOMANDE ?ALL)
                   (import DOMANDEPRINCIPALI ?ALL)
                   (import DOMINIO ?ALL)
                   (import REGOLE ?ALL)
                   (export ?ALL))

(defrule RICERCA::punteggio-balneare
  (attributo (nome balneare) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (balneare ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule RICERCA::punteggio-montano
  (attributo (nome montano) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (montano ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule RICERCA::punteggio-lacustre
  (attributo (nome lacustre) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (lacustre ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule RICERCA::punteggio-naturalistico
  (attributo (nome naturalistico) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (naturalistico ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule RICERCA::punteggio-termale
  (attributo (nome termale) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (termale ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule RICERCA::punteggio-culturale
  (attributo (nome culturale) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (culturale ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule RICERCA::punteggio-religioso
  (attributo (nome religioso) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (religioso ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule RICERCA::punteggio-sportivo
  (attributo (nome sportivo) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (sportivo ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule RICERCA::punteggio-enogastronomico
  (attributo (nome enogastronomico) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (enogastronomico ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(deftemplate RICERCA::distanza
  (slot partenza)
  (slot arrivo)
  (slot valore)
)

(defrule RICERCA::distanza-citta
  (localita (nome ?nome1) (cordN ?n1) (cordE ?e1))
  (localita (nome ?nome2) (cordN ?n2) (cordE ?e2))
  (test (neq ?nome1 ?nome2))
  =>
  (assert (distanza (partenza ?nome1) (arrivo ?nome2) (valore (calcola-distanza ?n1 ?n2 ?e1 ?e2))))
)

(defrule RICERCA::punteggio-albergo
  (albergo (nome ?nome) (stelle ?stelleAlbergo) (costoNotte ?costoNotte))
  (attributo (nome numGiorni) (valore ?giorni))
  (attributo (nome numPersone) (valore ?persone))
  (attributo (nome budget) (valore ?budget))
  (attributo (nome numStelle) (valore ?stelleUtente))
  =>
  (bind ?budgetNotte (/ ?budget (- ?giorni 1) (div (+ ?persone 1) 2)))
  (bind ?risparmio (- ?budgetNotte ?costoNotte))
  (bind ?certezza (* 100 (- (* 2 (/ (+ ?risparmio ?budgetNotte) (+ (/ ?budgetNotte 2) ?budgetNotte))) 1)))
  (bind ?certezza (controlla-certezza ?certezza))
  (bind ?certezza (punteggio-stelle ?stelleUtente ?stelleAlbergo ?certezza))
  (assert (attributo (nome albergoValutato) (valore ?nome) (certezza (controlla-certezza ?certezza))))
)

;************************
; COSTRUZIONE TOUR
;***********************
(defmodule TOUR (import MAIN ?ALL)
                (import DOMANDE ?ALL)
                (import DOMANDEPRINCIPALI ?ALL)
                (import DOMINIO ?ALL)
                (import REGOLE ?ALL)
                (import RICERCA ?ALL) (export ?ALL))

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

(defrule TOUR::rimuovi-permutazioni-tour
  (declare (salience 3))
  ?t1 <- (tour (listaCitta $?listaCitta1) (listaAlberghi $?listaAlberghi1))
  ?t2 <- (tour (listaCitta $?listaCitta2) (listaAlberghi $?listaAlberghi2))
  (test (eq (length$ ?listaCitta1) (length$ ?listaCitta2)))
  (test (neq ?listaCitta1 ?listaCitta2))
  (test (neq ?listaAlberghi1 ?listaAlberghi2))
  (test (subsetp ?listaCitta1 ?listaCitta2))
  (test (subsetp ?listaAlberghi1 ?listaAlberghi2))
  =>
  (retract ?t2)
)

(defrule TOUR::rimuovi-tour-ridondanti
  (declare (salience 3))
  ?t1 <- (tour (listaCitta $?listaCitta1) (certezza ?certezza1))
  ?t2 <- (tour (listaCitta $?listaCitta2) (certezza ?certezza2&:(< ?certezza2 ?certezza1)))
  (test (eq (length$ ?listaCitta1) (length$ ?listaCitta2)))
  (test (or (subsetp (subseq$ ?listaCitta2 1 (+ 1 (div (length$ ?listaCitta2) 2))) ?listaCitta1)
            (subsetp (subseq$ ?listaCitta2 (div (length$ ?listaCitta2) 2) (length$ ?listaCitta2)) ?listaCitta1)))
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

;************************
; MODULO STAMPA
;************************
(defmodule STAMPA (import MAIN ?ALL)
                  (import DOMANDE ?ALL)
                  (import DOMANDEPRINCIPALI ?ALL)
                  (import DOMINIO ?ALL)
                  (import REGOLE ?ALL)
                  (import RICERCA ?ALL)
                  (import TOUR ?ALL)
                  (export ?ALL))

;(defrule STAMPA::stampa-citta
;  (declare (salience 10))
;  ?citta <- (attributo (nome cittaValutata) (valore ?nome) (certezza ?certezza))
;  (not (attributo (nome cittaValutata) (certezza ?per1&:(> ?per1 ?certezza)))) ;non esiste una citta che abbia una certezza maggiore
;  =>
;  (retract ?citta)
;  (format t " %-24s %2d%%%n" ?nome ?certezza))
;
;(defrule STAMPA::rimuovi-citta-scarse
;  (declare (salience 20))
;  ?citta <- (attributo (nome cittaValutata) (certezza ?per&:(< ?per 80)))
;  =>
;  (retract ?citta))

;(defrule STAMPA::stampa-punteggio
;  ?punteggio <- (attributo (nome ?tipologia&:(or (eq ?tipologia balneare)
;                                                  (eq ?tipologia montano)
;                                                  (eq ?tipologia naturalistico)
;                                                  (eq ?tipologia termale)
;                                                  (eq ?tipologia culturale)
;                                                  (eq ?tipologia religioso)
;                                                  (eq ?tipologia sportivo)
;                                                  (eq ?tipologia enogastronomico)
;                                                  (eq ?tipologia lacustre))) (valore ?b) (certezza ?cb))
;  =>
;  (retract ?punteggio)
;  (format t " %-24s %d %2d%%%n" ?tipologia ?b ?cb)
;)

(defrule STAMPA::stampa-tour
  (declare (salience 10))
  ?s <- (soluzioni ?soluzioni&:(< ?soluzioni 5))
  ?tour <- (tour (listaCitta $?citta)
                 (listaAlberghi $?alberghi)
                 (listaStelle $?stelle)
                 (listaCosti $?costi)
                 (listaNotti $?notti)
                 (costoTour ?costotot)
                 (certezza ?certezza))
  (not (tour (certezza ?certezza1&:(> ?certezza1 ?certezza))))
  =>
  (bind ?soluzioni (+ 1 ?soluzioni))
  (stampa-tour ?soluzioni ?citta ?alberghi ?stelle ?costi ?notti ?certezza ?costotot)
  (retract ?tour)
  (retract ?s)
  (assert (soluzioni ?soluzioni))
)

;(defrule STAMPA::rimuovi-tour-scarsi
;  (declare (salience 20))
;  ?tour <- (tour (certezza ?certezza&:(< ?certezza 80)))
;  =>
;  (retract ?tour))

;(defrule STAMPA::stampa-albergo
;  (declare (salience 10))
;  ?albergo <- (attributo (nome albergoValutato) (valore ?nome) (certezza ?certezza))
;  (not (attributo (nome albergoValutato) (certezza ?per1&:(> ?per1 ?certezza)))) ;non esiste una citta che abbia una certezza maggiore
;  =>
;  (retract ?albergo)
;  (format t " %-24s %2d%%%n" ?nome ?certezza)
;)


(defrule STAMPA::rimuovi-alberghi-scarsi
  (declare (salience 20))
  ?albergo <- (attributo (nome albergoValutato) (certezza ?per&:(< ?per 50)))
  =>
  (retract ?albergo))
