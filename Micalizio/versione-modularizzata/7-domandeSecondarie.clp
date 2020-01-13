;******************************
; DOMANDE SECONDARIE
;******************************
(defmodule DOMANDESECONDARIE (import MAIN ?ALL)
                             (import DOMANDE ?ALL)
                             (import TOUR ?ALL)
                             (export ?ALL))

(defrule DOMANDESECONDARIE::pulisci-memoria
  (fase 2)
  =>
  (do-for-all-facts ((?t tour)) TRUE (retract ?t))
  (do-for-all-facts ((?a attributo)) (eq ?a:nome albergoValutato) (retract ?a))
)

(defrule DOMANDESECONDARIE::domande-secondarie
  ?r <- (attributo (nome continuaRicerca) (valore si))

  =>
  (assert (templateDomanda (attributo tradizione_natura)
                   (domanda "Preferisci conoscere le TRADIZIONI del posto o passeggiare nella NATURA?")
                   (risposteValide tradizioni natura indifferente)
                   (precursore tradizione_natura is indifferente)))
  (assert (templateDomanda (attributo spiaggia_spa)
                   (domanda "Preferisci andare in SPIAGGIA o in una SPA?")
                   (risposteValide spiaggia spa indifferente)
                   (precursore spiaggia_spa is indifferente)))
  (assert (templateDomanda (attributo numStelle)
                   (domanda "Hai preferenze sul numero di stelle degli alberghi?")
                   (risposteValide 1 2 3 4 no)
                   (precursore numStelle is no)))
  (assert (templateDomanda (attributo regioneDaEvitare)
                   (domanda "Vuoi evitare una regione in particolare?")
                   (risposteValide valledaosta piemonte lombardia veneto liguria trentino veneto emiliaromagna toscana umbria abruzzo lazio campania marche puglia basilicata calabria sicilia sardegna no)))

  (retract ?r)

  (focus DOMANDE
         REGOLE
         PUNTEGGIO
         TOUR
         STAMPA)
)
