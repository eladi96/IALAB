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
  (focus DOMANDE))

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



;;*********************
;; MODULO DOMANDE
;;*********************
(defmodule DOMANDE (import MAIN ?ALL) (export ?ALL))

; Template delle domande
(deftemplate DOMANDE::templateDomanda
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

; Elenco delle domande che saranno chieste all'utente.
(deffacts DOMANDE::elencoDomande
  (templateDomanda (attributo numGiorni)
                   (domanda "Quanti giorni deve durare il viaggio?")
                   (risposteValide interoPositivo))
  (templateDomanda (attributo numPersone)
                   (domanda "Quante persone parteciperanno?")
                   (risposteValide interoPositivo))
  (templateDomanda (attributo numLuoghi)
                   (domanda "Quanti luoghi vorreste visitare?")
                   (risposteValide interoPositivo))
  (templateDomanda (attributo regionePrincipale)
                   (domanda "Avete preferenze sulla regione da visitare?")
                   (risposteValide valledaosta piemonte liguria lombardia trentino veneto friuli toscana emiliaRomagna marche umbria lazio abruzzo campania molise basilicata puglia calabria sicilia sardegna no))
  (templateDomanda (attributo regioneDaEvitare)
                   (domanda "C'e' una regione che vorreste evitare?")
                   (risposteValide valledaosta piemonte liguria lombardia trentino veneto friuli toscana emiliaRomagna marche umbria lazio abruzzo campania molise basilicata puglia calabria sicilia sardegna no))
  (templateDomanda (attributo budget)
                   (domanda "A quanto ammonta il vostro budget?")
                   (risposteValide interoPositivo))
  (templateDomanda (attributo stelleAlbergo)
                   (domanda "Avete preferenze sul numero di stelle degli Alberghi?")
                   (risposteValide no 1 2 3 4))
  (templateDomanda (attributo localitaPrincipale)
                   (domanda "Avete preferenze sul tipo di localita'?")
                   (risposteValide balneare montano lacustre naturalistico termale culturale religioso sportivo enogastronomico no))
  (templateDomanda (attributo localitaDaEvitare)
                   (domanda "Volete evitare qualche tipologia di localita'?")
                   (risposteValide balneare montano lacustre naturalistico termale culturale religioso sportivo enogastronomico no)))
