;***********************
; MODULO PUNTEGGIO
;***********************
(defmodule PUNTEGGIO (import MAIN ?ALL)
                     (import DOMINIO ?ALL)
                     (export ?ALL))

;*******************************************************************************
; Calcolo delle certezze da associare alle località in base alle risposte date 
; dall’utente e ai fatti asseriti durante l’esecuzione del modulo REGOLE

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
;*******************************************************************************

;*******************************************************************************
; Calcolo della certezza degli alberghi in base alle informazioni su budget
; e preferenza sul numero di stelle

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
;*******************************************************************************
