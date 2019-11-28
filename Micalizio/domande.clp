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
