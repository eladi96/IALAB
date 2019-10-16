
% Predicato da invocare per far partire la ricerca
astar(Soluzione):-
  iniziale(S),
  finale(F),
  distEuclidea(S, F, F_costo_iniziale),
  astar_aux([nodo(S, F_costo_iniziale, [])], [], Soluzione).

%-------------------------------------------------------------------------------
% Predicati ausiliari per la ricerca A*
% astar_aux(Coda,Visitati,Soluzione)

% Passo base: lo stato attuale è lo stato finale: la soluzione è uguale alla
% lista delle azioni effettuate per raggiungerlo
astar_aux([nodo(S, _, Azioni)|_], _, Azioni):-finale(S),!.

% Passo ricorsivo: preso il nodo in testa alla coda, che sarà quello con F_costo
% minore, si trovano tutte le azioni applicabili al nodo e si generano i suoi
% figli, che saranno inseriti in coda in ordine crescente di F_costo. In seguito
% è richiamato ricorsivamente A* sulla nuova coda.
astar_aux([nodo(S, F_costo, Azioni)|Coda], Visitati, SoluzioneParziale):-
    findall(Azione, applicabile(Azione,S), ListaApplicabili),
    generaFigli(nodo(S, F_costo, Azioni), ListaApplicabili, [S|Visitati], Coda, NuovaCoda),
    astar_aux(NuovaCoda, [S|Visitati], SoluzioneParziale).

%-------------------------------------------------------------------------------
% Predicati per la generazione dei nodi figli di un nodo
%generaFigli(Nodo, AzioniApplicabili, Visitati, CodaAttuale, NuovaCoda)

% Quando la lista di azioni applicabili è consumata,associa il valore della coda
% ottenuta a quello della coda da utilizzare per la prossima ricorsione di astar
generaFigli(_, [], _, Coda, Coda).

% Passo ricorsivo
generaFigli(nodo(S, F_costo, AzioniPerS), [Azione|AltreAzioni], Visitati, Coda, NuovaCoda):-
    % Applica l'azione e ottieni il nuovo stato (la nuova posizione)
    muovi(Azione, S, SNuovo),
    % Controlla che l'azione non porti in uno stato già visitato
    \+member(SNuovo, Visitati), !,
    % Associa a Fine lo stato finale
    finale(Fine),
    % Conta i passi effettuati per giungere allo stato attuale
    % TODO sostituisci con gcosto([AzioniPerS], G_costo) per costo non unitario
    length(AzioniPerS, N),
    % Calcola la distanza euclidea dallo stato nuovo allo stato finale
    distEuclidea(SNuovo, Fine, Distanza),
    % Calcola l'f costo del nuovo nodo sommando i passi effettuati alla distanza
    % TODO sostituisci con G_costo + Distanza per costo non unitario
    F_costoNuovo is N + Distanza,
    % Inserisce il nodo ottenuto nella coda, in base all'ordine crescente di
    % f costo
    inserisciInCoda(nodo(SNuovo, F_costoNuovo, [Azione|AzioniPerS]), Coda, NuovaCodaParziale),
    % Richiama il predicato con le successive azioni applicabili
    generaFigli(nodo(S, F_costo, AzioniPerS), AltreAzioni, Visitati, NuovaCodaParziale, NuovaCoda).

% Predicato utilizzato per "saltare" una azione nella lista delle azioni
% applicabili nel caso in cui porti ad una posizione già visitata
generaFigli(nodo(S, F_costo, AzioniPerS), [_|AltreAzioni], Visitati, Coda, NuovaCoda):-
    generaFigli(nodo(S, F_costo, AzioniPerS), AltreAzioni, Visitati, Coda, NuovaCoda).

%-------------------------------------------------------------------------------
% Euristica

% Utilizzata come euristica per la ricerca informata la Distanza Euclidea
distEuclidea(pos(X1, Y1), pos(Xfinale, Yfinale), Distanza):-
  Distanza is sqrt((X1 - Xfinale)^2 + (Y1 - Yfinale)^2).

%-------------------------------------------------------------------------------
% Predicati per il calcolo del g costo di un Nodo
% gCosto(ListaAzioni, G_costo)

% Se la lista di azioni è vuota, il costo è zero
gCosto([], 0).

% Somma ricorsiva dei costi delle azioni applicate
gCosto([Azione|AltreAzioni], G_costo_totale):-
  gCosto(AltreAzioni, G_costo_parziale),
  costo(Azione, G_costo),
  G_costo_totale is G_costo_parziale + G_costo.

%-------------------------------------------------------------------------------
% Predicati per inserire i figli generati nella coda in ordine crescente di
% F_costo
% inserisciInCoda(Nodo, CodaAttuale, NuovaCoda)

% Passo base: se la coda è vuota, inserisci il nodo nella coda vuota
inserisciInCoda(nodo(S, F_costo, Azioni), [], [nodo(S, F_costo, Azioni)]).

% Passo immediato: se l'f costo del nodo generato è minore del costo del nodo in
% testa alla coda, inserisco il nuovo nodo in testa

inserisciInCoda(nodo(S, F_costo, Azioni),
                [nodo(Stesta, F_costo_minimo, Azionitesta) | RestoCoda],
                [nodo(S, F_costo, Azioni), nodo(Stesta, F_costo_minimo, Azionitesta) | RestoCoda]) :-
  F_costo =< F_costo_minimo.

% Passo ricorsivo: se l'f costo del nodo generato è maggiore del costo del nodo
% in testa alla coda, richiamo il predicato con il resto della coda.
inserisciInCoda(nodo(S, F_costo, Azioni),
                [nodo(Stesta, F_costo_minimo, Azionitesta) | RestoCodaParziale],
                [nodo(Stesta, F_costo_minimo, Azionitesta) | RestoCoda]) :-
  inserisciInCoda(nodo(S, F_costo, Azioni), RestoCodaParziale, RestoCoda).
