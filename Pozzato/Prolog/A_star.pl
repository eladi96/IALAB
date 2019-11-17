% Costo delle Azioni
% TODO poni il costo di tutte le azioni a 1 per costo uniforme
costo(sud, 1).
costo(ovest, 1).
costo(nord, 1).
costo(est, 1).

% Predicato da invocare per far partire la ricerca
astar(SoluzioneOrdinata):-
  iniziale(S),
  hMiglioreUscita(S, F_costo_iniziale),
  astar_aux([nodo(S, F_costo_iniziale, [])], [], Soluzione),
  reverse(SoluzioneOrdinata, Soluzione),
  gCosto(SoluzioneOrdinata, CostoCammino),
  write(CostoCammino).

%-------------------------------------------------------------------------------
% Predicati ausiliari per la ricerca A*
% astar_aux(Coda,Visitati,Soluzione)

% Passo base: lo stato attuale è lo stato finale: la soluzione è uguale alla
% lista delle azioni effettuate per raggiungerlo
astar_aux([nodo(S, _, Azioni)|_], _, Azioni):-finale(S).

% Passo ricorsivo: preso il nodo in testa alla coda, che sarà quello con F_costo
% minore, si trovano tutte le azioni applicabili al nodo e si generano i suoi
% figli, che saranno inseriti in coda in ordine crescente di F_costo. In seguito
% è richiamato ricorsivamente A* sulla nuova coda.
astar_aux([nodo(S, F_costo, Azioni)|Coda], Visitati, SoluzioneParziale):-
    findall(Azione, applicabile(Azione,S), ListaApplicabili),
    generaFigli(nodo(S, F_costo, Azioni), ListaApplicabili, [S|Visitati], Coda, NuovaCoda),
    astar_aux(NuovaCoda, [S|Visitati], SoluzioneParziale).

% Questo predicato è valutato solo quando la coda è vuota, e l'uscita non è stata trovata
astar_aux([], _, _):-
  write("Non vi sono soluzioni possibili.").

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
    % Controlla che l'azione non porti in uno stato già visitato o in uno già
    % presente nella frontiera
    \+member(SNuovo, Visitati),
    % Conta i passi effettuati per giungere allo stato attuale
    gCosto(AzioniPerS, G_costo),
    % Calcola l'euristica dallo stato nuovo allo stato finale
    hMiglioreUscita(SNuovo, H),
    % Calcola l'f costo del nuovo nodo sommando i passi effettuati alla distanza
    F_costoNuovo is G_costo + H,
    % Inserisce il nodo ottenuto nella coda, in base all'ordine crescente di f costo
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
% Predicato per inserire i figli generati nella coda. Se il nodo da inserire ha
% lo stesso stato di un nodo già presente nella coda si effettua una sostituzione,
% solo nel caso in cui l'F_costo del nuovo nodo sia minore di quello del nodo
% già presente, altrimenti si effettua un inserimento.

inserisciInCoda(nodo(S, F_costo, Azioni), CodaAttuale, NuovaCoda):-
  nuovoInCoda(S, CodaAttuale),
  inserisciNuovo(nodo(S, F_costo, Azioni), CodaAttuale, NuovaCoda).

inserisciInCoda(nodo(S, F_costo, Azioni), CodaAttuale, NuovaCoda):-
  \+nuovoInCoda(S, CodaAttuale),
  rimuoviCostoMaggiore(nodo(S, F_costo, Azioni), CodaAttuale, NuovaCodaParziale),
  inserisciNuovo(nodo(S, F_costo, Azioni), NuovaCodaParziale, NuovaCoda).
%-------------------------------------------------------------------------------
% Predicati per inserire un nuovo nodo nella coda in ordine crescente di
% F_costo
% inserisciNuovo(Nodo, CodaAttuale, NuovaCoda)

% Passo base: se la coda è vuota, inserisci il nodo nella coda vuota
inserisciNuovo(nodo(S, F_costo, Azioni), [], [nodo(S, F_costo, Azioni)]).

% Passo immediato: se l'f costo del nodo nuovo è minore o uguale al costo del
% nodo in testa alla coda, inserisco il nuovo nodo in testa
inserisciNuovo(nodo(S, F_costo, Azioni),
                [nodo(Stesta, F_costo_minimo, Azionitesta) | RestoCoda],
                [nodo(S, F_costo, Azioni), nodo(Stesta, F_costo_minimo, Azionitesta) | RestoCoda]) :-
  F_costo =< F_costo_minimo.

% Passo ricorsivo: se l'f costo del nodo generato è maggiore del costo del nodo
% in testa alla coda, richiamo il predicato con il resto della coda.
inserisciNuovo(nodo(S, F_costo, Azioni),
                [nodo(Stesta, F_costo_minimo, Azionitesta) | RestoCodaParziale],
                [nodo(Stesta, F_costo_minimo, Azionitesta) | RestoCoda]) :-
  inserisciNuovo(nodo(S, F_costo, Azioni), RestoCodaParziale, RestoCoda).

%-------------------------------------------------------------------------------
% Predicato utilizzato per rimuovere un nodo dalla coda in caso ve ne sia uno nuovo
% con stesso stato e F_costo minore.
rimuoviCostoMaggiore(nodo(S, F_costo, _),
                    [nodo(Stesta, F_costo_testa, _) | RestoCoda],
                    RestoCoda) :-
  stessaPosizione(S, Stesta),
  F_costo < F_costo_testa.

rimuoviCostoMaggiore(nodo(S, F_costo, _),
                    [nodo(Stesta, F_costo_testa, _) | RestoCoda],
                    [nodo(Stesta, F_costo_testa, _) | RestoCodaNuova]) :-
  \+stessaPosizione(S, Stesta),
  rimuoviCostoMaggiore(nodo(S, F_costo, _), RestoCoda, RestoCodaNuova).
%-------------------------------------------------------------------------------
% Predicati ausiliari per l'inserimento dei nodi nella

% nuovoInCoda(StatoNuovo, CodaAttuale)
% Soddisfatto se nella coda non vi è nessuno nodo con lo stesso stato
nuovoInCoda(_, []).

nuovoInCoda(SNuovo, [nodo(STesta, _, _) | RestoCoda]):-
  \+stessaPosizione(SNuovo, STesta),
  nuovoInCoda(SNuovo, RestoCoda).

% Controlla che due posizioni siano uguali
stessaPosizione(pos(X1, Y1), pos(X2, Y2)):-
  X1 = X2,
  Y1 = Y2.

%-------------------------------------------------------------------------------
% Predicato per trovare l'uscita più vicina in base alla euristica.

hMiglioreUscita(Attuale, H):-
  % Trova tutte le uscite possibili
  findall(Finale, finale(Finale), ListaUscite),
  hMiglioreUscita_aux(Attuale, ListaUscite, H).

% Passo base: l'uscita migliore è l'unica in elenco
% miglioreUscita_aux(StatoAttuale, ListaUscite, UscitaMigliore)
hMiglioreUscita_aux(Attuale, [UscitaCorrente], H):-
  distEuclidea(Attuale, UscitaCorrente, H).

% Passo ricorsivo
hMiglioreUscita_aux(Attuale, [UscitaCorrente|RestoUscite], Hcorrente):-
  hMiglioreUscita_aux(Attuale, RestoUscite, HMiglioreparziale),
  distEuclidea(Attuale, UscitaCorrente, Hcorrente),
  Hcorrente < HMiglioreparziale.

% Passo ricorsivo
hMiglioreUscita_aux(Attuale, [UscitaCorrente|RestoUscite], HMiglioreParziale):-
  hMiglioreUscita_aux(Attuale, RestoUscite, HMiglioreParziale),
  distEuclidea(Attuale, UscitaCorrente, Hcorrente),
  Hcorrente >= HMiglioreParziale.
