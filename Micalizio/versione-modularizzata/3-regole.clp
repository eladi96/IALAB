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
