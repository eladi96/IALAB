;***********************
; MODULO PUNTEGGIO
;***********************
(defmodule PUNTEGGIO (import MAIN ?ALL)
                   (import DOMANDE ?ALL)
                   (import DOMANDEPRINCIPALI ?ALL)
                   (import DOMINIO ?ALL)
                   (import REGOLE ?ALL)
                   (export ?ALL))

(defrule PUNTEGGIO::punteggio-balneare
  (attributo (nome balneare) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (balneare ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule PUNTEGGIO::punteggio-montano
  (attributo (nome montano) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (montano ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule PUNTEGGIO::punteggio-lacustre
  (attributo (nome lacustre) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (lacustre ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule PUNTEGGIO::punteggio-naturalistico
  (attributo (nome naturalistico) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (naturalistico ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule PUNTEGGIO::punteggio-termale
  (attributo (nome termale) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (termale ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule PUNTEGGIO::punteggio-culturale
  (attributo (nome culturale) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (culturale ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule PUNTEGGIO::punteggio-religioso
  (attributo (nome religioso) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (religioso ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule PUNTEGGIO::punteggio-sportivo
  (attributo (nome sportivo) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (sportivo ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(defrule PUNTEGGIO::punteggio-enogastronomico
  (attributo (nome enogastronomico) (valore ?p) (certezza ?c))
  (localita (nome ?nome)
            (enogastronomico ?p))
  =>
  (assert (attributo (nome cittaValutata) (valore ?nome) (certezza ?c)))
)

(deftemplate PUNTEGGIO::distanza
  (slot partenza)
  (slot arrivo)
  (slot valore)
)

(defrule PUNTEGGIO::distanza-citta
  (localita (nome ?nome1) (cordN ?n1) (cordE ?e1))
  (localita (nome ?nome2) (cordN ?n2) (cordE ?e2))
  (test (neq ?nome1 ?nome2))
  =>
  (assert (distanza (partenza ?nome1) (arrivo ?nome2) (valore (calcola-distanza ?n1 ?n2 ?e1 ?e2))))
)

(defrule PUNTEGGIO::punteggio-albergo
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
