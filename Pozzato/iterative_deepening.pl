
% Passo base della ricerca iterativa
iterative_deepening(Soluzione, Soglia):-
  depth_limit_search(Soluzione, Soglia).

% Passo ricorsivo della ricerca iterativa: se non è stata trovata una soluzione
% con la soglia precedente, essa viene richiamata dopo aver incrementato la soglia.
iterative_deepening(Soluzione, Soglia):-
  NuovaSoglia is Soglia + 1,
  iterative_deepening(Soluzione, NuovaSoglia).

% Ricerca in profondità limitata.
depth_limit_search(Soluzione,Soglia):-
    iniziale(S),
    dfs_aux(S,Soluzione,[S],Soglia).

% Passo base della ricerca in profondità limitata: lo stato in cui mi
% trovo è lo stato finale del problema.
dfs_aux(S,[],_,_):-finale(S).

% Passo ricorsivo della ricerca in profondità limitata: ad ogni azione
% compiuta decremento la soglia, in modo che se non trovo la soluzione prima
% che la soglia arrivi a zero interrompo la ricerca.
dfs_aux(S,[Azione|AzioniTail],Visitati,Soglia):-
    Soglia>0,
    applicabile(Azione,S),
    muovi(Azione,S,SNuovo),
    \+member(SNuovo,Visitati),
    NuovaSoglia is Soglia-1,
    dfs_aux(SNuovo,AzioniTail,[SNuovo|Visitati],NuovaSoglia).
