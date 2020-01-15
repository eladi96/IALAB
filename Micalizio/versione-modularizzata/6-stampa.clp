;************************
; MODULO STAMPA
;************************
(defmodule STAMPA (import MAIN ?ALL)
                  (import TOUR ?ALL)
                  (export ?ALL))

; regola per raffinare la soluzione proposta:
; vengono riproposta all'utente tutte le domande ignorate nella prima fase e
; se vuole evitare una regione particolare
(defrule STAMPA::continua-ricerca
  (declare (salience 1))
  ?s <- (soluzioni ?soluzioni&:(> ?soluzioni 0))
  ?f <- (fase 1)
  =>
  (assert (attributo (nome continuaRicerca)
                     (valore (chiedi-domanda "Vuoi raffinare la tua ricerca?" (create$ si no)))))
  (if (any-factp ((?r attributo)) (and (eq ?r:nome continuaRicerca) (eq ?r:valore si))) then
      (retract ?s ?f)
      (assert (soluzioni 0) (fase 2))
      (focus DOMANDESECONDARIE))
  )

; regola per stampare le soluzioni proposte all'utente
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

; eliminiamo tour con certezza inferiore a 70
(defrule STAMPA::rimuovi-tour-scarsi
  (declare (salience 20))
  ?tour <- (tour (certezza ?certezza&:(< ?certezza 70)))
  =>
  (retract ?tour))
