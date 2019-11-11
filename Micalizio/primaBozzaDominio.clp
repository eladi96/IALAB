(deftemplate localita
  (slot nome (type STRING))
  (slot regione (type STRING))
  (slot cordX)
  (slot cordY)
  ;; Inseriamo un valore da 0 a 5 per ogni tipo di turismo
  (slot tipoBalneare (type INTEGER) (range 0 5))
  (slot tipoMontano (type INTEGER) (range 0 5))
  (slot tipoLacustre (type INTEGER) (range 0 5))
  (slot tipoNaturalistico (type INTEGER) (range 0 5))
  (slot tipoTermale (type INTEGER) (range 0 5))
  (slot tipoCulturale (type INTEGER) (range 0 5))
  (slot tipoReligioso (type INTEGER) (range 0 5))
  (slot tipoSportivo (type INTEGER) (range 0 5))
  (slot tipoEnogastronomico (type INTEGER) (range 0 5)))

(deftemplate albergo
  (slot nome (type STRING))
  (slot stelle (type INTEGER) (range 1 4))
  (slot costoNotte (type FLOAT) (range 50.0 150.0))
  (slot camereLibere (type INTEGER) (range 0 ?VARIABLE))
  (slot camereOccupate (type INTEGER) (range 0 ?VARIABLE))
  (slot localita))

(deftemplate visitaTuristica
  (slot numPersone (type INTEGER) (range 0 ?VARIABLE))
  (slot localita)
  (slot numGiorni (type INTEGER) (range 1 ?VARIABLE)))
