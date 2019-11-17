;;*************************
;; MODULO MAIN
;;*************************
(defmodule MAIN (export ?ALL))

;; Template degli attributi che useremo per calcolare la soluzione
(deftemplate MAIN::attributo
  (slot nome)
  (slot valore)
  (slot certezza (default 100.0)))

;; Regola che da inizio all'esecuzione
(defrule MAIN::start
  (declare (salience 10000))
  =>
  (set-fact-duplication TRUE)
  (focus DOMINIO DOMANDE DOMANDEPRINCIPALI REGOLE RICERCA STAMPA))

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

(deffunction MAIN::calcola-certezza(?c1 ?c2)
  (bind ?nuovaCertezza 0)
  (bind ?c1 (/ ?c1 100))
  (bind ?c2 (/ ?c2 100))
  (if (and (> ?c1 0) (> ?c2 0)) then
      (bind ?nuovaCertezza (* 100 (- (+ ?c1 ?c2) (* ?c1 ?c2)))))
  (if (and (< ?c1 0) (< ?c2 0)) then
      (bind ?nuovaCertezza (* 100 (+ (+ ?c1 ?c2) (* ?c1 ?c2)))))
  (if (< (* ?c1 ?c2) 0) then
      (bind ?nuovaCertezza (* 100 (/ (+ ?c1 ?c2) (- 1.01 (min (abs ?c1) (abs ?c2)))))))
  ?nuovaCertezza
)

(deffunction MAIN::calcola-distanza(?n1 ?n2 ?e1 ?e2)
  (bind ?s1 (sin (- 90 ?n1)))
  (printout t "s1 = " ?s1)
  (bind ?s2 (sin (- 90 ?n2)))
  (printout t "s2 = " ?s2)
  (bind ?c1 (cos (- 90 ?n1)))
  (printout t "c1 = " ?c1)
  (bind ?c2 (cos (- 90 ?n2)))
  (printout t "c2 = " ?c2)
  (bind ?FI (cos (abs (- ?e1 ?e2))))
  (printout t "FI = " ?FI) ; angolo tra i due punti con vertice nel centro della terra
  (bind ?dist (* 6372.7955 (acos (+ (* ?c1 ?c2) (* ?FI ?s1 ?s2)))))
  (printout t ?dist crlf)
  ?dist
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
  (slot giaChiesta (default FALSE)))

; Regola che fa avviare la richiesta delle domande. Esse saranno chieste solo se
; il valore giaChiesta valga FALSE, e diventerà TRUE una volta che la domanda sicilia
; stata chiesta.
(defrule DOMANDE::chiedi-una-domanda
   ?f <- (templateDomanda (giaChiesta FALSE)
                   (domanda ?domanda)
                   (attributo ?attributo)
                   (risposteValide $?risposteValide))
   =>
   (modify ?f (giaChiesta TRUE))
   (assert (attributo (nome ?attributo)
                      (valore (chiedi-domanda ?domanda ?risposteValide)))))

;******************************
; DOMANDE PRINCIPALI
;******************************
(defmodule DOMANDEPRINCIPALI (import MAIN ?ALL) (import DOMANDE ?ALL) (export ?ALL))

(deffacts DOMANDEPRINCIPALI::elencoDomandePrincipali
  (templateDomanda (attributo numGiorni)
                   (domanda "Quanti giorni deve durare il viaggio?")
                   (risposteValide interoPositivo))
  (templateDomanda (attributo numPersone)
                   (domanda "Quante persone parteciperanno?")
                   (risposteValide interoPositivo))
  ; Se non chiediamo i giorni all'inizio, proponiamo una soluzione che abbia un numero numLuoghi pari a numGiorni / 2
  (templateDomanda (attributo budget)
                   (domanda "A quanto ammonta il vostro budget?")
                   (risposteValide interoPositivo))
  (templateDomanda (attributo culturale_rilassante)
                   (domanda "Preferisci una vacanza culturale o rilassante?")
                   (risposteValide culturale rilassante indifferente))
  (templateDomanda (attributo mare_montagna)
                   (domanda "Preferisci luoghi di mare o di montagna?")
                   (risposteValide mare montagna indifferente))
)

;******************************
; REGOLE
;******************************
(defmodule REGOLE (import MAIN ?ALL) (import DOMANDE ?ALL) (import DOMANDEPRINCIPALI ?ALL) (export ?ALL))

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
  (modify ?attr2 (certezza (calcola-certezza ?c1 ?c2))))

(deffacts REGOLE::regole-tour
  (regola (if culturale_rilassante is culturale)
          (then culturale is 5 with certezza 100 and
                culturale is 4 with certezza 80 and
                culturale is 3 with certezza 40 and
                culturale is 2 with certezza 0 and
                culturale is 1 with certezza -40 and
                culturale is 0 with certezza -80 and
                religioso is 5 with certezza 60 and
                religioso is 4 with certezza 30 and
                religioso is 3 with certezza 10 and
                religioso is 2 with certezza 0 and
                religioso is 1 with certezza -20 and
                religioso is 0 with certezza -40 and
                enogastronomico is 5 with certezza 60 and
                enogastronomico is 4 with certezza 30 and
                enogastronomico is 3 with certezza 10 and
                enogastronomico is 2 with certezza 0 and
                enogastronomico is 1 with certezza -20 and
                enogastronomico is 0 with certezza -40))
  (regola (if culturale_rilassante is rilassante)
          (then balneare is 5 with certezza 80 and
                balneare is 4 with certezza 60 and
                balneare is 3 with certezza 40 and
                balneare is 2 with certezza 0 and
                balneare is 1 with certezza -40 and
                balneare is 0 with certezza -80 and
                termale is 5 with certezza 100 and
                termale is 4 with certezza 90 and
                termale is 3 with certezza 50 and
                termale is 2 with certezza 0 and
                termale is 1 with certezza -40 and
                termale is 0 with certezza -60 and
                lacustre is 5 with certezza 60 and
                lacustre is 4 with certezza 30 and
                lacustre is 3 with certezza 10 and
                lacustre is 2 with certezza 0 and
                lacustre is 1 with certezza -20 and
                lacustre is 0 with certezza -40 and
                naturalistico is 5 with certezza 60 and
                naturalistico is 4 with certezza 30 and
                naturalistico is 3 with certezza 10 and
                naturalistico is 2 with certezza 0 and
                naturalistico is 1 with certezza -20 and
                naturalistico is 0 with certezza -40))
    (regola (if mare_montagna is mare)
            (then balneare is 5 with certezza 100 and
                  balneare is 4 with certezza 90 and
                  balneare is 3 with certezza 50 and
                  balneare is 2 with certezza 0 and
                  balneare is 1 with certezza -60 and
                  balneare is 0 with certezza -100
                  lacustre is 5 with certezza 80 and
                  lacustre is 4 with certezza 40 and
                  lacustre is 3 with certezza 20 and
                  lacustre is 2 with certezza 0 and
                  lacustre is 1 with certezza -20 and
                  lacustre is 0 with certezza -40 and
                  sportivo is 5 with certezza 60 and
                  sportivo is 4 with certezza 30 and
                  sportivo is 3 with certezza 10 and
                  sportivo is 2 with certezza 0 and
                  sportivo is 1 with certezza -20 and
                  sportivo is 0 with certezza -40))
    (regola (if mare_montagna is montagna)
            (then montano is 5 with certezza 100 and
                  montano is 4 with certezza 90 and
                  montano is 3 with certezza 50 and
                  montano is 2 with certezza 0 and
                  montano is 1 with certezza -60 and
                  montano is 0 with certezza -100 and
                  sportivo is 5 with certezza 80 and
                  sportivo is 4 with certezza 40 and
                  sportivo is 3 with certezza 20 and
                  sportivo is 2 with certezza 0 and
                  sportivo is 1 with certezza -20 and
                  sportivo is 0 with certezza -40 and
                  naturalistico is 5 with certezza 80 and
                  naturalistico is 4 with certezza 40 and
                  naturalistico is 3 with certezza 20 and
                  naturalistico is 2 with certezza 0 and
                  naturalistico is 1 with certezza -20 and
                  naturalistico is 0 with certezza -40 and
                  lacustre is 5 with certezza 60 and
                  lacustre is 4 with certezza 30 and
                  lacustre is 3 with certezza 10 and
                  lacustre is 2 with certezza 0 and
                  lacustre is 1 with certezza -20 and
                  lacustre is 0 with certezza -40 and
                  termale is 5 with certezza 60 and
                  termale is 4 with certezza 30 and
                  termale is 3 with certezza 10 and
                  termale is 2 with certezza 0 and
                  termale is 1 with certezza -20 and
                  termale is 0 with certezza -40))
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

(deftemplate RICERCA::cittaValutata
  (slot nome)
  (slot certezza)
)

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
  (localita (nome "Roma") (cordN ?n1) (cordE ?e1))
  (localita (nome "Milano") (cordN ?n2) (cordE ?e2))
  ;(test (neq ?nome1 ?nome2))
  =>
  (printout t Roma " " Milano ": ")
  (assert (distanza (partenza Roma) (arrivo Milano) (valore (calcola-distanza ?n1 ?n2 ?e1 ?e2))))
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
                  (export ?ALL))

(defrule STAMPA::stampa-citta
  ?citta <- (attributo (nome cittaValutata) (valore ?nome) (certezza ?certezza))
  (not (attributo (nome cittaValutata) (certezza ?per1&:(> ?per1 ?certezza)))) ;non esiste una citta che abbia una certezza maggiore
  =>
  (retract ?citta)
  (format t " %-24s %2d%%%n" ?nome ?certezza))

(defrule STAMPA::rimuovi-citta-scarse
  ?citta <- (attributo (nome cittaValutata) (certezza ?per&:(< ?per 50)))
  =>
  (retract ?citta))
