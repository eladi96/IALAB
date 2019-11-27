%Goal: calendario settimanale

% ORARIO
#const orariosettimanale = 30.
#const numgiorni = 5.
#const orelezionialgiorno = 6.

#const ore_sett_lettere = 10.
#const ore_sett_math = 4.
#const ore_sett_scienze = 2.
#const ore_sett_inglese = 3.
#const ore_sett_spagnolo = 2.
#const ore_sett_musica = 2.
#const ore_sett_tec = 2.
#const ore_sett_arte = 2.
#const ore_sett_edFisica = 2.
#const ore_sett_religione = 1.
giorno(lunedi; martedi; mercoledi; giovedi; venerdi).
ora(1..6).

%CLASSI
#const numero_classi = 6.
classe("1A"; "1B";"2A"; "2B"; "3A"; "3B"). % A = regime fulltime => mensa
                                            % B = regime parttime => no mensa

% AULE e LAB
aula(aula1; aula2; aula3; aula4; aula5; aula6; aula7; aula8; palestra; lab_scienze; lab_arte).

% MATERIE
materia(religione; tecnologia; musica; lettere; inglese; spagnolo; matematica; arte; scienze; edFisica).
%materia_in_lab(arte; scienze; edFisica).

% DOCENTI
%docente_lab(profArte; profScienze; profEdFisica).
docente(profReligione; profTec; profMusica; profIng; profSpagnolo; profLettere1; profLettere2; profArte; prof_Math_Scienze1; prof_Math_Scienze2; profEdFisica).
% #TODO insegnanti plurimi


% REGIME
regime(fulltime; parttime).


%ASSEGNAZIONE MATERIA-AULA
1{assegna_materia_aula(A, M):materia(M) } 1:- aula(A).
{assegna_materia_aula(A, M):aula(A) } 2:- materia(M).

%vincolo che mi permettere di dire che a "lettere" vanno assegnate 2 aule
2{assegna_materia_aula(A, M) : assegna_materia_aula(A, M), M=lettere}.

%ASSEGNAZIONE DOCENTE-MATERIA
1{assegna_materia_docente(D, M):materia(M) } 1:- docente(D).
{assegna_materia_docente(D, M):docente(D) } 2:- materia(M).


%LEZIONI
numgiorni {lezioni_giornaliere(G, O):ora(O)} orelezionialgiorno  :- giorno(G).
numgiorni {lezioni_giornaliere(G, O):giorno(G)} orelezionialgiorno :- ora(O).

numero_classi {lezione_per_classe(G, O, C):lezioni_giornaliere(G, O)} orariosettimanale*numero_classi  :- classe(C).
{lezione_per_classe(G, O, C):classe(C)}orariosettimanale*numero_classi :- lezioni_giornaliere(G, O).


ore_sett_religione*numero_classi{lezione_religione(D, M, A, G, O, C) : assegna_materia_docente(D, M), assegna_materia_aula(A, M), lezione_per_classe(G, O, C), M=religione}.
ore_sett_tec*numero_classi{lezione_tec(D, M, A, G, O, C) : assegna_materia_docente(D, M), assegna_materia_aula(A, M), lezione_per_classe(G, O, C), M=tecnologia}.
ore_sett_inglese*numero_classi{lezione_inglese(D, M, A, G, O, C) : assegna_materia_docente(D, M), assegna_materia_aula(A, M), lezione_per_classe(G, O, C), M=inglese}.
ore_sett_musica*numero_classi{lezione_musica(D, M, A, G, O, C) : assegna_materia_docente(D, M), assegna_materia_aula(A, M), lezione_per_classe(G, O, C), M=musica}.
ore_sett_spagnolo*numero_classi{lezione_spagnolo(D, M, A, G, O, C) : assegna_materia_docente(D, M), assegna_materia_aula(A, M), lezione_per_classe(G, O, C), M=spagnolo}.
ore_sett_math*numero_classi{lezione_math(D, M, A, G, O, C) : assegna_materia_docente(D, M), assegna_materia_aula(A, M), lezione_per_classe(G, O, C), M=matematica}.
ore_sett_lettere*numero_classi{lezione_lettere(D, M, A, G, O, C) : assegna_materia_docente(D, M), assegna_materia_aula(A, M), lezione_per_classe(G, O, C), M=lettere}.

ore_sett_arte*numero_classi{lezione_arte(D, M, L, G, O, C) : assegna_materia_docente(D, M), assegna_materia_aula(L, M), lezione_per_classe(G, O, C), M=arte}.
ore_sett_scienze * numero_classi{lezione_scienze(D, M, L, G, O, C) : assegna_materia_docente(D, M), assegna_materia_aula(L, M), lezione_per_classe(G, O, C), M=scienze}.
ore_sett_edFisica*numero_classi{lezione_edFisica(D, M, L, G, O, C) : assegna_materia_docente(D, M), assegna_materia_aula(L, M), lezione_per_classe(G, O, C), M=edFisica}.



goal:-  assegna_materia_docente(profArte, arte),
        assegna_materia_docente(profEdFisica, edFisica),
        assegna_materia_docente(profReligione, religione),
        assegna_materia_docente(prof_Math_Scienze1, scienze),
        assegna_materia_docente(prof_Math_Scienze2, matematica),
        assegna_materia_docente(profMusica, musica),
        assegna_materia_docente(profTec, tecnologia),
        assegna_materia_docente(profLettere1, lettere),
        assegna_materia_docente(profLettere2, lettere),
        assegna_materia_docente(profIng, inglese),
        assegna_materia_docente(profSpagnolo, spagnolo),
        assegna_materia_aula(palestra, edFisica),
        assegna_materia_aula(lab_arte, arte),
        assegna_materia_aula(lab_scienze, scienze).
:- not goal.


%*#TODO integrity constraint????
1) Quello che non può accedere è che un aula risulti non assegnata.
2) Quello che non può accedere è che un docente risulti senza materia assegnata, ma può essere libero.
*%


%#show assegna_materia_docente/2.
#show assegna_materia_aula/2.

%#show lezione_inglese/6.
%#show lezione_tec/6.
%#show lezione_spagnolo/6.
%#show lezione_math/6.
%#show lezione_lettere/6.
%#show lezione_musica/6.
#show lezione_religione/6.
%#show lezione_arte/6.
%#show lezione_edFisica/6.*%
%#show lezione_scienze/6.
%#show lezioni_giornaliere/2.
%#show lezione_per_classe/3.
