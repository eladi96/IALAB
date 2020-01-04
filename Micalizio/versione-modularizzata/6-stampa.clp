;************************
; MODULO STAMPA
;************************
(defmodule STAMPA (import MAIN ?ALL)
                  (import DOMANDE ?ALL)
                  (import DOMANDEPRINCIPALI ?ALL)
                  (import DOMINIO ?ALL)
                  (import REGOLE ?ALL)
                  (import PUNTEGGIO ?ALL)
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
(defrule STAMPA::continua-ricerca
  (declare (salience 1))
  ?s <- (soluzioni ?soluzioni&:(> ?soluzioni 0))
  ?f <- (fase 1)
  =>
  (assert (attributo (nome continuaRicerca)
                     (valore (chiedi-domanda "Vuoi raffinare la tua ricerca?" (create$ si no)))))

  (retract ?s ?f)
  (assert (soluzioni 0) (fase 2))

  (focus DOMANDESECONDARIE)
  )

(defrule STAMPA::stampa-tour
  (declare (salience 10))
  ?s <- (soluzioni ?soluzioni&:(< ?soluzioni 6))
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

(defrule STAMPA::rimuovi-tour-scarsi
  (declare (salience 20))
  ?tour <- (tour (certezza ?certezza&:(< ?certezza 80)))
  =>
  (retract ?tour))

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
