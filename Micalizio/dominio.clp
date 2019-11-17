;*****************************
; MODULO DOMINIO
;*****************************
(defmodule DOMINIO (export ?ALL))

(deftemplate DOMINIO::localita
  (slot nome (type STRING))
  (slot regione (type STRING))
  (slot cordN)
  (slot cordE)
  ;; Inseriamo un valore da 0 a 5 per ogni tipo di turismo
  (slot balneare (type INTEGER) (range 0 5))
  (slot montano (type INTEGER) (range 0 5))
  (slot lacustre (type INTEGER) (range 0 5))
  (slot naturalistico (type INTEGER) (range 0 5))
  (slot termale (type INTEGER) (range 0 5))
  (slot culturale (type INTEGER) (range 0 5))
  (slot religioso (type INTEGER) (range 0 5))
  (slot sportivo (type INTEGER) (range 0 5))
  (slot enogastronomico (type INTEGER) (range 0 5)))

(deftemplate DOMINIO::albergo
  (slot nome (type STRING))
  (slot stelle (type INTEGER) (range 1 4))
  (slot costoNotte (type FLOAT) (range 50.0 125.0))
  (slot localita))

(deftemplate DOMINIO::visitaTuristica
  (slot numPersone (type INTEGER) (range 0 ?VARIABLE))
  (slot localita)
  (slot numGiorni (type INTEGER) (range 1 ?VARIABLE)))

(deffacts DOMINIO::lista-localita
  (localita (nome "Aosta")       (regione "valledaosta")      (cordN 45.73) (cordE 7.31) (balneare 0) (montano 5) (lacustre 0) (naturalistico 4) (termale 3) (culturale 4) (religioso 2) (sportivo 2) (enogastronomico 4))
  (localita (nome "Courmayer")   (regione "valledaosta")      (cordN 45.79) (cordE 6.97) (balneare 0) (montano 5) (lacustre 0) (naturalistico 5) (termale 3) (culturale 1) (religioso 0) (sportivo 3) (enogastronomico 4))
  (localita (nome "Torino")      (regione "piemonte")         (cordN 45.07) (cordE 7.68) (balneare 0) (montano 4) (lacustre 1) (naturalistico 2) (termale 1) (culturale 5) (religioso 3) (sportivo 5) (enogastronomico 3))
  (localita (nome "Milano")      (regione "lombardia")        (cordN 45.46) (cordE 9.18) (balneare 0) (montano 0) (lacustre 1) (naturalistico 0) (termale 0) (culturale 5) (religioso 2) (sportivo 5) (enogastronomico 3))
  (localita (nome "Como")        (regione "lombardia")        (cordN 45.80) (cordE 9.08) (balneare 0) (montano 3) (lacustre 5) (naturalistico 4) (termale 1) (culturale 3) (religioso 0) (sportivo 0) (enogastronomico 3))
  (localita (nome "Sirmione")    (regione "lombardia")        (cordN 45.49) (cordE 10.60) (balneare 4) (montano 0) (lacustre 5) (naturalistico 5) (termale 5) (culturale 2) (religioso 0) (sportivo 0) (enogastronomico 3))
  (localita (nome "Trento")      (regione "trentino")         (cordN 46.07) (cordE 11.11) (balneare 0) (montano 5) (lacustre 1) (naturalistico 3) (termale 3) (culturale 4) (religioso 2) (sportivo 1) (enogastronomico 4))
  (localita (nome "Venezia")     (regione "veneto")           (cordN 45.44) (cordE 12.31) (balneare 4) (montano 0) (lacustre 2) (naturalistico 2) (termale 2) (culturale 5) (religioso 3) (sportivo 1) (enogastronomico 3))
  (localita (nome "Cortina")     (regione "veneto")           (cordN 46.54) (cordE 12.13) (balneare 0) (montano 5) (lacustre 0) (naturalistico 5) (termale 1) (culturale 2) (religioso 0) (sportivo 3) (enogastronomico 4))
  (localita (nome "Moena")       (regione "veneto")           (cordN 46.37) (cordE 11.66) (balneare 0) (montano 5) (lacustre 3) (naturalistico 4) (termale 1) (culturale 2) (religioso 0) (sportivo 3) (enogastronomico 4))
  (localita (nome "Trieste")     (regione "friuli")           (cordN 45.65) (cordE 13.77) (balneare 4) (montano 0) (lacustre 0) (naturalistico 2) (termale 2) (culturale 3) (religioso 2) (sportivo 0) (enogastronomico 2))
  (localita (nome "Bologna")     (regione "emiliaromagna")    (cordN 44.49) (cordE 11.34) (balneare 0) (montano 1) (lacustre 0) (naturalistico 1) (termale 0) (culturale 5) (religioso 4) (sportivo 3) (enogastronomico 5))
  (localita (nome "Firenze")     (regione "toscana")          (cordN 43.78) (cordE 11.24) (balneare 0) (montano 0) (lacustre 0) (naturalistico 2) (termale 4) (culturale 5) (religioso 4) (sportivo 3) (enogastronomico 5))
  (localita (nome "Montecatini") (regione "toscana")          (cordN 43.88) (cordE 10.77) (balneare 0) (montano 2) (lacustre 0) (naturalistico 3) (termale 5) (culturale 3) (religioso 1) (sportivo 0) (enogastronomico 3))
  (localita (nome "Saturnia")    (regione "toscana")          (cordN 42.65) (cordE 11.51) (balneare 0) (montano 1) (lacustre 0) (naturalistico 4) (termale 5) (culturale 3) (religioso 1) (sportivo 0) (enogastronomico 3))
  (localita (nome "Assisi")      (regione "umbria")           (cordN 43.06) (cordE 12.62) (balneare 0) (montano 3) (lacustre 2) (naturalistico 4) (termale 0) (culturale 4) (religioso 5) (sportivo 0) (enogastronomico 4))
  (localita (nome "Perugia")     (regione "umbria")           (cordN 43.11) (cordE 12.39) (balneare 0) (montano 3) (lacustre 4) (naturalistico 4) (termale 2) (culturale 3) (religioso 3) (sportivo 3) (enogastronomico 4))
  (localita (nome "Aquila")      (regione "abruzzo")          (cordN 42.37) (cordE 13.35) (balneare 0) (montano 3) (lacustre 2) (naturalistico 4) (termale 1) (culturale 3) (religioso 2) (sportivo 1) (enogastronomico 3))
  (localita (nome "Roma")        (regione "lazio")            (cordN 41.88) (cordE 12.52) (balneare 0) (montano 0) (lacustre 1) (naturalistico 4) (termale 2) (culturale 5) (religioso 5) (sportivo 5) (enogastronomico 5))
  (localita (nome "Napoli")      (regione "campania")         (cordN 40.85) (cordE 14.26) (balneare 4) (montano 0) (lacustre 0) (naturalistico 3) (termale 3) (culturale 4) (religioso 4) (sportivo 4) (enogastronomico 5))
  (localita (nome "Recanati")    (regione "marche")           (cordN 43.40) (cordE 13.55) (balneare 0) (montano 1) (lacustre 0) (naturalistico 3) (termale 0) (culturale 5) (religioso 1) (sportivo 0) (enogastronomico 3))
  (localita (nome "Loreto")      (regione "marche")           (cordN 43.43) (cordE 13.60) (balneare 1) (montano 2) (lacustre 0) (naturalistico 2) (termale 0) (culturale 4) (religioso 5) (sportivo 0) (enogastronomico 3))
  (localita (nome "Ancona")      (regione "marche")           (cordN 43.59) (cordE 13.50) (balneare 4) (montano 0) (lacustre 0) (naturalistico 3) (termale 1) (culturale 3) (religioso 3) (sportivo 1) (enogastronomico 3))
  (localita (nome "SanGiovanniRotondo") (regione "puglia")    (cordN 41.70) (cordE 15.72) (balneare 0) (montano 3) (lacustre 0) (naturalistico 3) (termale 0) (culturale 3) (religioso 5) (sportivo 0) (enogastronomico 3))
  (localita (nome "Bari") (regione "puglia")                  (cordN 41.11) (cordE 16.89) (balneare 5) (montano 0) (lacustre 0) (naturalistico 3) (termale 0) (culturale 4) (religioso 4) (sportivo 2) (enogastronomico 5))
  (localita (nome "Matera") (regione "basilicata")            (cordN 40.66) (cordE 16.60) (balneare 0) (montano 3) (lacustre 0) (naturalistico 4) (termale 2) (culturale 5) (religioso 3) (sportivo 0) (enogastronomico 4))
  (localita (nome "Tropea") (regione "calabria")              (cordN 38.67) (cordE 15.89) (balneare 5) (montano 0) (lacustre 0) (naturalistico 3) (termale 1) (culturale 2) (religioso 2) (sportivo 0) (enogastronomico 4))
  (localita (nome "Palermo") (regione "sicilia")              (cordN 38.11) (cordE 13.36) (balneare 5) (montano 1) (lacustre 0) (naturalistico 3) (termale 0) (culturale 4) (religioso 4) (sportivo 3) (enogastronomico 5))
  (localita (nome "Cagliari") (regione "sardegna")            (cordN 39.24) (cordE 9.12) (balneare 5) (montano 0) (lacustre 3) (naturalistico 2) (termale 0) (culturale 3) (religioso 2) (sportivo 1) (enogastronomico 3))
  (localita (nome "Genova") (regione "liguria")               (cordN 44.40) (cordE 8.94) (balneare 4) (montano 0) (lacustre 0) (naturalistico 4) (termale 0) (culturale 3) (religioso 1) (sportivo 2) (enogastronomico 3))
  )

(deffacts DOMINIO::lista-alberghi
  (albergo (nome "Norden") (stelle 3) (costoNotte 100.0) (localita "Aosta"))
  (albergo (nome "Roche") (stelle 2) (costoNotte 75.0) (localita "Aosta"))
  (albergo (nome "Bertod") (stelle 3) (costoNotte 100.0) (localita "Courmayer"))
  (albergo (nome "Gorret") (stelle 4) (costoNotte 125.0) (localita "Courmayer"))
  (albergo (nome "Royal") (stelle 2) (costoNotte 75.0) (localita "Torino"))
  (albergo (nome "Palace") (stelle 4) (costoNotte 125.0) (localita "Torino"))
  (albergo (nome "Ibis") (stelle 3) (costoNotte 100.0) (localita "Milano"))
  (albergo (nome "Klima") (stelle 4) (costoNotte 125.0) (localita "Milano"))
  (albergo (nome "Lizard") (stelle 2) (costoNotte 75.0) (localita "Como"))
  (albergo (nome "OstelloBello") (stelle 4) (costoNotte 125.0) (localita "Como"))
  (albergo (nome "GrandHotelTerme") (stelle 4) (costoNotte 125.0) (localita "Sirmione"))
  (albergo (nome "Eden") (stelle 1) (costoNotte 50.0) (localita "Sirmione"))
  (albergo (nome "Torrione") (stelle 1) (costoNotte 50.0) (localita "Trento"))
  (albergo (nome "Everest") (stelle 3) (costoNotte 100.0) (localita "Trento"))
  (albergo (nome "RioNovo") (stelle 4) (costoNotte 125.0) (localita "Venezia"))
  (albergo (nome "BelleArti") (stelle 2) (costoNotte 75.0) (localita "Venezia"))
  (albergo (nome "HotelCortina") (stelle 3) (costoNotte 100.0) (localita "Cortina"))
  (albergo (nome "VillaBlu") (stelle 2) (costoNotte 75.0) (localita "Cortina"))
  (albergo (nome "Faloria") (stelle 1) (costoNotte 50.0) (localita "Moena"))
  (albergo (nome "CasaDolce") (stelle 3) (costoNotte 100.0) (localita "Moena"))
  (albergo (nome "Centrale") (stelle 4) (costoNotte 125.0) (localita "Trieste"))
  (albergo (nome "AlbergoNascosto") (stelle 2) (costoNotte 75.0) (localita "Trieste"))
  (albergo (nome "Portici") (stelle 3) (costoNotte 100.0) (localita "Bologna"))
  (albergo (nome "Aemilia") (stelle 2) (costoNotte 75.0) (localita "Bologna"))
  (albergo (nome "Fiorino") (stelle 1) (costoNotte 50.0) (localita "Firenze"))
  (albergo (nome "PlusFlorence") (stelle 4) (costoNotte 125.0) (localita "Firenze"))
  (albergo (nome "Bartolini") (stelle 3) (costoNotte 100.0) (localita "Montecatini"))
  (albergo (nome "Tettuccio") (stelle 2) (costoNotte 75.0) (localita "Montecatini"))
  (albergo (nome "AnticaLocanda") (stelle 1) (costoNotte 50.0) (localita "Saturnia"))
  (albergo (nome "Clodia") (stelle 3) (costoNotte 100.0) (localita "Saturnia"))
  (albergo (nome "Giotto") (stelle 2) (costoNotte 75.0) (localita "Assisi"))
  (albergo (nome "Rocca") (stelle 3) (costoNotte 100.0) (localita "Assisi"))
  (albergo (nome "Primavera") (stelle 3) (costoNotte 100.0) (localita "Perugia"))
  (albergo (nome "Fortuna") (stelle 1) (costoNotte 50.0) (localita "Perugia"))
  (albergo (nome "FedericoSecondo") (stelle 1) (costoNotte 50.0) (localita "Aquila"))
  (albergo (nome "AquilaBianca") (stelle 2) (costoNotte 75.0) (localita "Aquila"))
  (albergo (nome "NuovaRoma") (stelle 4) (costoNotte 125.0) (localita "Roma"))
  (albergo (nome "Arcangelo") (stelle 3) (costoNotte 100.0) (localita "Roma"))
  (albergo (nome "Garde") (stelle 2) (costoNotte 75.0) (localita "Napoli"))
  (albergo (nome "Billia") (stelle 1) (costoNotte 50.0) (localita "Napoli"))
  (albergo (nome "Ginestra") (stelle 3) (costoNotte 100.0) (localita "Recanati"))
  (albergo (nome "CalaLaPasta") (stelle 1) (costoNotte 50.0) (localita "Recanati"))
  (albergo (nome "SanGabriele") (stelle 2) (costoNotte 75.0) (localita "Loreto"))
  (albergo (nome "Giardinetto") (stelle 3) (costoNotte 100.0) (localita "Loreto"))
  (albergo (nome "Passetto") (stelle 3) (costoNotte 100.0) (localita "Ancona"))
  (albergo (nome "Vittoria") (stelle 1) (costoNotte 50.0) (localita "Ancona"))
  (albergo (nome "SanPio") (stelle 1) (costoNotte 50.0) (localita "SanGiovanniRotondo"))
  (albergo (nome "Immagine") (stelle 2) (costoNotte 75.0) (localita "SanGiovanniRotondo"))
  (albergo (nome "Sheraton") (stelle 3) (costoNotte 100.0) (localita "Bari"))
  (albergo (nome "Excelsior") (stelle 4) (costoNotte 125.0) (localita "Bari"))
  (albergo (nome "Viceconte") (stelle 4) (costoNotte 125.0) (localita "Matera"))
  (albergo (nome "HotelSassi") (stelle 2) (costoNotte 75.0) (localita "Matera"))
  (albergo (nome "Vallemare") (stelle 2) (costoNotte 75.0) (localita "Tropea"))
  (albergo (nome "Tropice") (stelle 3) (costoNotte 100.0) (localita "Tropea"))
  (albergo (nome "Joly") (stelle 3) (costoNotte 100.0) (localita "Palermo"))
  (albergo (nome "VecchioBorgo") (stelle 2) (costoNotte 75.0) (localita "Palermo"))
  (albergo (nome "Panorama") (stelle 2) (costoNotte 75.0) (localita "Cagliari"))
  (albergo (nome "Poetto") (stelle 1) (costoNotte 50.0) (localita "Cagliari"))
  (albergo (nome "Olympia") (stelle 3) (costoNotte 100.0) (localita "Genova"))
  (albergo (nome "Fiume") (stelle 4) (costoNotte 125.0) (localita "Genova")))
