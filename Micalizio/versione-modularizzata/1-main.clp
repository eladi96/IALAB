;;*************************
;; MODULO MAIN
;; Questo modulo è usato semplicemente per avviare il sistema,
;; e come contenitore di funzioni utili ai fini dell’esecuzione.
;;*************************
(defmodule MAIN (export ?ALL))

;; Template degli attributi che useremo per calcolare la soluzione
(deftemplate MAIN::attributo
  (slot nome)
  (slot valore)
  (slot certezza (default 0.0)))

;; Regola che da inizio all'esecuzione
(defrule MAIN::start
  (declare (salience 10000))
  =>
  (set-fact-duplication TRUE)
  (assert (soluzioni 0))
  (assert (fase 1))
  (focus DOMINIO
         DOMANDE
         DOMANDEPRINCIPALI
         REGOLE
         PUNTEGGIO
         TOUR
         STAMPA))

; in base alla domanda posta, questa funzione si occupa controllare la risposta
; data dall'utente e se valida registrarla, in caso contrario continuerà a stampare la domanda
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

; funzione per combinare due certezze
(deffunction MAIN::combina-certezze(?c1 ?c2)
  (bind ?nuovaCertezza 0)
  (bind ?c1 (/ ?c1 100))
  (bind ?c2 (/ ?c2 100))
  (if (and (> ?c1 0) (> ?c2 0)) then
      (bind ?nuovaCertezza (* 100 (- (+ ?c1 ?c2) (* ?c1 ?c2)))))
  (if (and (< ?c1 0) (< ?c2 0)) then
      (bind ?nuovaCertezza (* 100 (+ (+ ?c1 ?c2) (* ?c1 ?c2)))))
  (if (<= (* ?c1 ?c2) 0) then
      (bind ?nuovaCertezza (* 100 (/ (+ ?c1 ?c2) (- 1.01 (min (abs ?c1) (abs ?c2)))))))
  ?nuovaCertezza
)

; controlla che il range di una certezza si compreso tra -100 e 100
; definisce quindi una soglia per i valori esterni all'intervallo
(deffunction MAIN::controlla-certezza(?c)
  (if (> ?c 100) then (bind ?c 100))
  (if (< ?c -100) then (bind ?c -100))
  ?c
)

; in base alle coordinate geografiche, calcola la distanza in linea d'aria sulla superficie terreste
(deffunction MAIN::calcola-distanza(?n1 ?n2 ?e1 ?e2)
  (bind ?s1 (sin (deg-rad (- 90 ?n1))))
  (bind ?s2 (sin (deg-rad (- 90 ?n2))))
  (bind ?c1 (cos (deg-rad (- 90 ?n1))))
  (bind ?c2 (cos (deg-rad (- 90 ?n2))))
  (bind ?FI (cos (deg-rad (abs (- ?e1 ?e2))))) ; angolo tra i due punti con vertice nel centro della terra
  (bind ?dist (* 6372.7955 (acos (+ (* ?c1 ?c2) (* ?FI ?s1 ?s2)))))
  ?dist
)

; stampa dei risultati
(deffunction MAIN::stampa-tour(?numeroTour ?listaCitta ?listaAlberghi ?listaStelle ?listaCosti ?listaNotti ?certezza ?costoComplessivo)
  (bind ?i 1)
  (format t "%nTOUR %-2d - PUNTEGGIO: %-3.2f - COSTO TOT.: %-7.2f%n%n" ?numeroTour ?certezza ?costoComplessivo)
  (format t "          CITTA                    ALBERGO          STELLE    COSTO NOTTE     NOTTI%n" )
  (while (<= ?i (length$ ?listaCitta)) do
    (bind ?citta (nth$ ?i ?listaCitta))
    (bind ?albergo (nth$ ?i ?listaAlberghi))
    (bind ?stelle (nth$ ?i ?listaStelle))
    (bind ?costo (nth$ ?i ?listaCosti))
    (bind ?notti (nth$ ?i ?listaNotti))
    (format t  "Tappa %-2d: %-25s%-20s%-10g%-15.2f%-10d%n" ?i ?citta ?albergo ?stelle ?costo ?notti)
    (bind ?i (+ 1 ?i))
  )
)

; se l'utente inserisce la preferenza sul numero di stelle,
; la certezza viene combinata prendendo alla certezza precedente,
; le stelle inserite dall'utente e le stelle dell'albergo considerato
(deffunction MAIN::punteggio-stelle(?stelleUtente ?stelleAlbergo ?certezza)
  (if (neq ?stelleUtente no) then
    (bind ?certezza (* ?certezza (- 1 (/ (abs (- ?stelleUtente ?stelleAlbergo)) 3))))
  )
  ?certezza
)

; divide equamente il numero totale delle notti per il numero di località visitate,
; e distribuisce l’eventuale resto di questa divisione aggiungendo notti alle località
; i cui alberghi hanno un prezzo minore
(deffunction MAIN::spartisci-notti(?numLocalita ?nottiPerLocalita ?nottiAvanzate ?costoNotte)
  (bind ?listaNotti (create$ ))
  (bind ?i 1)
  (while (<= ?i ?numLocalita) do
    (bind ?listaNotti (insert$ ?listaNotti ?i ?nottiPerLocalita))
    (if (> ?nottiAvanzate 0) then
      (bind ?nottiCorrente (nth$ ?i ?listaNotti))
      (bind ?listaNotti (replace$ ?listaNotti ?i ?i (+ ?nottiCorrente 1)))
      (bind ?nottiAvanzate (- ?nottiAvanzate 1))
    )
    (bind ?i (+ 1 ?i))
  )

  (bind ?i 1)
  (while (< ?i ?numLocalita) do
    (bind ?j (+ ?i 1))
    (while (<= ?j ?numLocalita) do
      (if (and (> (nth$ ?i ?costoNotte) (nth$ ?j ?costoNotte))
               (> (nth$ ?i ?listaNotti) (nth$ ?j ?listaNotti))
          ) then
        (bind ?temp (nth$ ?i ?listaNotti))
        (bind ?listaNotti (replace$ ?listaNotti ?i ?i (nth$ ?j ?listaNotti)))
        (bind ?listaNotti (replace$ ?listaNotti ?j ?j ?temp))
      )
      (bind ?j (+ 1 ?j))
    )
    (bind ?i (+ 1 ?i))
  )

  ?listaNotti
)

(deffunction MAIN::calcola-costo-tour(?costi ?persone ?notti)
  (bind ?costoComplessivo 0)
  (bind ?i 1)
  (while (<= ?i (length$ ?costi)) do
    (bind ?costoComplessivo (+ ?costoComplessivo (* (nth$ ?i ?notti) (nth$ ?i ?costi) (+ (div ?persone 2) (mod ?persone 2)))))
    (bind ?i (+ ?i 1))
  )
  ?costoComplessivo
)
