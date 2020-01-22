% COSTI DEI NODI
% Fatti per il calcolo del g costo di un Nodo.
costo(est, 1).
costo(ovest, 1).
costo(nord, 1).
costo(sud, 1).

% Se la lista di azioni è vuota, il costo è zero
gCosto([], 0).

% Somma ricorsiva dei costi delle azioni applicate
gCosto([Azione|AltreAzioni], G_costo_totale):-
    gCosto(AltreAzioni, G_costo_parziale),
    costo(Azione, G_costo),
    G_costo_totale is G_costo_parziale + G_costo.

iterative_deepening(Solu):-
  id(Solu, 0).

% Passo base della ricerca iterativa
id(Soluzione, Soglia):-
  depth_limit_search(Soluzione, Soglia),
  % quando ha trovato la soluzione, stampa il costo del cammino.
  gCosto(Soluzione, CostoCammino),
  write(CostoCammino).

% Passo ricorsivo della ricerca iterativa: se non è stata trovata una soluzione
% con la soglia precedente, essa viene richiamata dopo aver incrementato la soglia.
id(Soluzione, Soglia):-
  NuovaSoglia is Soglia + 1,
  num_righe(NR),
  num_colonne(NC),
  SogliaMax is (NR * NC) / 2,
  NuovaSoglia < SogliaMax,
  id(Soluzione, NuovaSoglia).

% Ricerca in profondità limitata.
depth_limit_search(Soluzione, Soglia):-
  iniziale(S),
  dfs_aux(S, Soluzione, [S], Soglia).

% Passo base della ricerca in profondità limitata: lo stato in cui mi
% trovo è lo stato finale del problema.
dfs_aux(S,[],_,_):-
  finale(S).

% Passo ricorsivo della ricerca in profondità limitata: ad ogni azione
% compiuta decremento la soglia, in modo che se non trovo la soluzione prima
% che la soglia arrivi a zero interrompo la ricerca.
dfs_aux(S,[Azione|AzioniTail], Visitati, Soglia):-
    Soglia>0,
    applicabile(Azione,S),
    muovi(Azione,S,SNuovo),
    \+member(SNuovo,Visitati),
    NuovaSoglia is Soglia-1,
    dfs_aux(SNuovo, AzioniTail,[SNuovo|Visitati], NuovaSoglia).
