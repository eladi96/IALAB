;******************************
; REGOLE
;
; In questo modulo sono contenuti fatti e regole che definiscono i punteggi di
; certezza da attribuire alle località in base al tipo di turismo preferito.
;******************************

(defmodule REGOLE (import MAIN ?ALL)
                  (export ?ALL))

(deftemplate REGOLE::regola
  (multislot if)
  (multislot then))

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
          (then montano is 5 with certezza 70
                montano is 4 with certezza 50
                montano is 3 with certezza 30
                montano is 2 with certezza 10
                montano is 1 with certezza 0
                montano is 0 with certezza -70

                naturalistico is 5 with certezza 70
                naturalistico is 4 with certezza 50
                naturalistico is 3 with certezza 30
                naturalistico is 2 with certezza 10
                naturalistico is 1 with certezza 0
                naturalistico is 0 with certezza -70

                sportivo is 5 with certezza 70
                sportivo is 4 with certezza 50
                sportivo is 3 with certezza 30
                sportivo is 2 with certezza 10
                sportivo is 1 with certezza 0
                sportivo is 0 with certezza -70

                culturale is 5 with certezza 70
                culturale is 4 with certezza 50
                culturale is 3 with certezza 30
                culturale is 2 with certezza 10
                culturale is 1 with certezza 0
                culturale is 0 with certezza -70

                ;negativi
                balneare is 5 with certezza -70
                balneare is 4 with certezza -50
                balneare is 3 with certezza -30
                balneare is 2 with certezza -10
                balneare is 1 with certezza 0
                balneare is 0 with certezza 50

                lacustre is 5 with certezza -70
                lacustre is 4 with certezza -50
                lacustre is 3 with certezza -30
                lacustre is 2 with certezza -10
                lacustre is 1 with certezza 0
                lacustre is 0 with certezza 50

                termale is 5 with certezza -70
                termale is 4 with certezza -50
                termale is 3 with certezza -30
                termale is 2 with certezza -10
                termale is 1 with certezza 0
                termale is 0 with certezza 50 ))

  (regola (if scarpe_costume is costume)
          (then balneare is 5 with certezza 70
                balneare is 4 with certezza 50
                balneare is 3 with certezza 30
                balneare is 2 with certezza 10
                balneare is 1 with certezza 0
                balneare is 0 with certezza -70

                termale is 5 with certezza 70
                termale is 4 with certezza 50
                termale is 3 with certezza 30
                termale is 2 with certezza 10
                termale is 1 with certezza 0
                termale is 0 with certezza -70

                lacustre is 5 with certezza 70
                lacustre is 4 with certezza 50
                lacustre is 3 with certezza 30
                lacustre is 2 with certezza 10
                lacustre is 1 with certezza 0
                lacustre is 0 with certezza -70

                sportivo is 5 with certezza 50
                sportivo is 4 with certezza 40
                sportivo is 3 with certezza 30
                sportivo is 2 with certezza 20
                sportivo is 1 with certezza 10
                sportivo is 0 with certezza 0

                ;negativi

                montano is 5 with certezza -70
                montano is 4 with certezza -50
                montano is 3 with certezza -30
                montano is 2 with certezza -10
                montano is 1 with certezza 0
                montano is 0 with certezza 70 ))

  (regola (if spiaggia_spa is spiaggia)
          (then balneare is 5 with certezza 80
                balneare is 4 with certezza 60
                balneare is 3 with certezza 40
                balneare is 2 with certezza 20
                balneare is 1 with certezza 0
                balneare is 0 with certezza -80

                ;negativi
                termale is 5 with certezza -80
                termale is 4 with certezza -60
                termale is 3 with certezza -40
                termale is 2 with certezza -20
                termale is 1 with certezza 0
                termale is 0 with certezza 80 ))

  (regola (if spiaggia_spa is spa)
          (then termale is 5 with certezza 80
                termale is 4 with certezza 60
                termale is 3 with certezza 40
                termale is 2 with certezza 20
                termale is 1 with certezza 0
                termale is 0 with certezza -80

                ;negativi
                balneare is 5 with certezza -80
                balneare is 4 with certezza -60
                balneare is 3 with certezza -40
                balneare is 2 with certezza -20
                balneare is 1 with certezza 0
                balneare is 0 with certezza 80

                sportivo is 5 with certezza -70
                sportivo is 4 with certezza -50
                sportivo is 3 with certezza -30
                sportivo is 2 with certezza -10
                sportivo is 1 with certezza 0
                sportivo is 0 with certezza 70 ))

(regola (if tradizione_natura is tradizioni)
        (then enogastronomico is 5 with certezza 80
              enogastronomico is 4 with certezza 60
              enogastronomico is 3 with certezza 40
              enogastronomico is 2 with certezza 20
              enogastronomico is 1 with certezza 0
              enogastronomico is 0 with certezza -80

              culturale is 5 with certezza 80
              culturale is 4 with certezza 60
              culturale is 3 with certezza 40
              culturale is 2 with certezza 20
              culturale is 1 with certezza 0
              culturale is 0 with certezza -80

              religioso is 5 with certezza 80
              religioso is 4 with certezza 60
              religioso is 3 with certezza 40
              religioso is 2 with certezza 20
              religioso is 1 with certezza 0
              religioso is 0 with certezza -80

              ; negativi
              sportivo is 5 with certezza -60
              sportivo is 4 with certezza -40
              sportivo is 3 with certezza -30
              sportivo is 2 with certezza -20
              sportivo is 1 with certezza 0
              sportivo is 0 with certezza 60

              naturalistico is 5 with certezza -60
              naturalistico is 4 with certezza -40
              naturalistico is 3 with certezza -30
              naturalistico is 2 with certezza -20
              naturalistico is 1 with certezza 0
              naturalistico is 0 with certezza 60 ))

(regola (if tradizione_natura is natura)
        (then naturalistico is 5 with certezza 80
              naturalistico is 4 with certezza 60
              naturalistico is 3 with certezza 40
              naturalistico is 2 with certezza 20
              naturalistico is 1 with certezza 0
              naturalistico is 0 with certezza -80

              sportivo is 5 with certezza 80
              sportivo is 4 with certezza 60
              sportivo is 3 with certezza 40
              sportivo is 2 with certezza 20
              sportivo is 1 with certezza 0
              sportivo is 0 with certezza -80

              ; negativi
              religioso is 5 with certezza -60
              religioso is 4 with certezza -40
              religioso is 3 with certezza -30
              religioso is 2 with certezza -20
              religioso is 1 with certezza 0
              religioso is 0 with certezza 60

              enogastronomico is 5 with certezza -60
              enogastronomico is 4 with certezza -40
              enogastronomico is 3 with certezza -30
              enogastronomico is 2 with certezza -20
              enogastronomico is 1 with certezza 0
              enogastronomico is 0 with certezza 60

              culturale is 5 with certezza -60
              culturale is 4 with certezza -40
              culturale is 3 with certezza -30
              culturale is 2 with certezza -20
              culturale is 1 with certezza 0
              culturale is 0 with certezza 60 ))
)
