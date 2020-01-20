%Goal: calendario settimanale per ogni aula

% ORARIO
#const orariosettimanale = 30.
#const numgiorni = 5.
#const orelezionialgiorno = 6.

%* per ogni classe, sono previste 10 ore di lettere, 4 di
matematica, 2 di scienze, 3 di inglese, 2 di spagnolo, 2
di musica, 2 di tecnologia, 2 di arte, 2 di educazione
fisica, 1 di religione.*%
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
classe("1A";"1B";"2A"; "2B"; "3A"; "3B"). % A = regime fulltime => mensa
                                             % B = regime parttime => no mensa
% 11 AULE
aula(aula1; aula2; aula3; aula4; aula5; aula6; aula7; aula8; palestra; lab_scienze; lab_arte).

% 10 MATERIE
materia(religione; tecnologia; musica; lettere; inglese; spagnolo; arte; edFisica; matematica; scienze).

% 13 DOCENTI.
docente(profReligione; profTec; profMusica; profIng; profSpagnolo; profLettere1; profLettere2; profArte; profEdFisica; prof_Math1; prof_Math2).

% REGIME
regime(fulltime; parttime).


% ASSEGNAZIONE CLASSE REGIME
% Ad ogni classe assegno 1 solo regime.
1 {ha_regime(C, R):regime(R)} 1 :- classe(C).
% Ad ogni regime posso assegnare al più tutte le classi
{ha_regime(C, R):classe(C)} numero_classi:- regime(R).

va_in_mensa(C, R):- ha_regime(C,R), R=fulltime.


% ASSEGNAZIONE MATERIA-AULA
% Ad ogni aula, assegno una sola materia
1{assegna_materia_aula(A, M):materia(M) } 1:- aula(A).
% Ad ogni materia, assegno 1 o al più 2 aule (il caso di lettere)
1{assegna_materia_aula(A, M):aula(A) } 1:- materia(M), M!=lettere.
1{assegna_materia_aula(A, M):aula(A) } 2:- materia(M), M=lettere.
%1{assegna_materia_aula(A, M):aula(A) } 2:- materia(M).

% ASSEGNAZIONE DOCENTE-MATERIA
% Ad ogni docente, assegno 1 o al più due materie
1{assegna_materia_docente(D, M):materia(M)} 2:- docente(D).
% Se non insegna mat, insegna una ed una sola una materia
1 {assegna_materia_docente(D,M) : materia(M)} 1 :- docente(D), not assegna_materia_docente(D, matematica).
% Ad ogni materia, assegno 1 o al più due docenti
1{assegna_materia_docente(D, M):docente(D)} 2:- materia(M).
% Ma nel caso non si tratti di let, mat o sci, allora vi è solo un docente per quella materia
1 { assegna_materia_docente(D,M) : docente(D) } 1 :- materia(M), M != lettere, M != matematica, M != scienze.


assegna_materia_docente(D, matematica):-assegna_materia_docente(D, scienze).
assegna_materia_docente(D, scienze):-assegna_materia_docente(D, matematica).
%LEZIONI

% Ad ogni ora di lezione giornaliera assegno uno giorno, e ciò viene replicato per ogni giorno ==>(lunedì, 1a ora) ==> 6 ore per ogni giorno
numgiorni{lezioni_giornaliere(G, O) : giorno(G)} orelezionialgiorno :- ora(O).


%Per ogni classe creo le ore di lezione che deve fare in settimana per ogni materia (associandovi anche aula e docente)
ore_sett_religione{ora_per_materia(religione, G, O, C) : lezioni_giornaliere(G, O)} ore_sett_religione :-classe(C).
ore_sett_tec{ora_per_materia(tecnologia, G, O, C) : lezioni_giornaliere(G, O)}ore_sett_tec :- classe(C).
ore_sett_inglese{ora_per_materia(inglese, G, O, C) : lezioni_giornaliere(G, O)} ore_sett_inglese :- classe(C).
ore_sett_musica{ora_per_materia(musica, G, O, C) :  lezioni_giornaliere(G, O)} ore_sett_musica :- classe(C).
ore_sett_spagnolo{ora_per_materia(spagnolo, G, O, C) : lezioni_giornaliere(G, O)} ore_sett_spagnolo :- classe(C).
ore_sett_math{ora_per_materia(matematica, G, O, C) : lezioni_giornaliere(G, O)} ore_sett_math :- classe(C).
ore_sett_lettere{ora_per_materia(lettere, G, O, C) : lezioni_giornaliere(G, O)}ore_sett_lettere :- classe(C).

ore_sett_arte{ora_per_materia( arte, G, O, C) : lezioni_giornaliere(G, O)} ore_sett_arte :- classe(C).
ore_sett_scienze{ora_per_materia( scienze, G, O, C) :  lezioni_giornaliere(G, O)}ore_sett_scienze  :- classe(C).
ore_sett_edFisica{ora_per_materia(edFisica, G, O, C) :  lezioni_giornaliere(G, O)} ore_sett_edFisica :- classe(C).
1{aula_occupata(A, M, G, O, C) : assegna_materia_aula(A, M) }1 :- ora_per_materia(M,G,O,C).



1 {insegna(D,M,C) : assegna_materia_docente(D,M)} 1 :- materia(M), classe(C).

docente_impegnato(D,M,C,G,O) :- ora_per_materia(M,G,O, C), insegna(D,M,C).

lezione(D,M,A, G,O, C) :- docente_impegnato(D,M,C,G,O), aula_occupata(A, M,G,O, C).


goal:-  assegna_materia_docente(profArte, arte),
        assegna_materia_docente(profEdFisica, edFisica),
        assegna_materia_docente(profReligione, religione),
        assegna_materia_docente(profMusica, musica),
        assegna_materia_docente(profTec, tecnologia),
        assegna_materia_docente(profLettere1, lettere),
        assegna_materia_docente(profLettere2, lettere),
        assegna_materia_docente(profIng, inglese),
        assegna_materia_docente(profSpagnolo, spagnolo),
        assegna_materia_aula(palestra, edFisica),
        assegna_materia_aula(lab_arte, arte),
        assegna_materia_aula(lab_scienze, scienze),
        ha_regime("1A", fulltime),
        ha_regime("2A", fulltime),
        ha_regime("3A", fulltime),
        ha_regime("1B", parttime).
        ha_regime("2B", parttime),
        ha_regime("3B", parttime).

% Limita a due il massimo numero giornaliero di ore per una data materia
{ ora_per_materia(M,G,O, C) : ora(O) } 2 :- classe(C), materia(M), giorno(G).
% Due ore consecutive della stessa materia quando possibile (NEW VERSION)
%ora_per_materia(M,G,O+1,C) :- ora_per_materia(M,G,O,C), (O \ 2) == 1, M != rel.



%INTEGRITY CONSTRAINTS:
%Quello che non può accedere è che:

% 0) i vincoli posti nel goal non vengano rispettati
:- not goal.

:-docente_impegnato(D1,_,C,G,O), docente_impegnato(D2,_,C,G,O), D1!=D2.

:-aula_occupata(M, A, G, O, C1), aula_occupata(M, A, G, O, C2), C1!=C2.
:-aula_occupata(M1, A1, G, O, C), aula_occupata(M2, A2, G, O, C), M1!=M2.
:-aula_occupata(M1, A1, G, O, C), aula_occupata(M2, A2, G, O, C), A1!=A2.

% Non è possibile cambiare aula a cavallo di una lezione (di fatto solo per letteratura).
% Qui il modulo non è strettamente necessario ma velocizza la ricerca di soluzioni.
:- lezione(D,M,A1,G,O, C), lezione(D,M,A2,G,O+1,C), A1 != A2, (O \ 2) == 1.



% STAMPE
%#show aula_occupata/5.
%#show insegna/3.
%#show assegna_materia_docente/2.
#show assegna_materia_aula/2.
%#show ha_regime/2.
#show va_in_mensa/2.
%#show ora_per_materia/4.
%#show docente_impegnato/5.

#show lezione/6.
%#show lezioni_giornaliere/2.
