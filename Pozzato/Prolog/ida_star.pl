%-------------------------------------------------------------------------------
% ALGORTIMO IDA*
% due sezioni principali
% 1) regole e fatti di supporto all'algoritmo ida*
% 2) vero e proprio algoritmo ida*
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% UTILI AI FINI DELL'ALGORITMO
%-------------------------------------------------------------------------------
% COSTI DEI NODI
% Fatti per il calcolo del g costo di un Nodo.
costo(est, 1).
costo(ovest, 1).
costo(nord, 1).
costo(sud, 1).
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% CALCOLO DEL G_COSTO
% il gCosto è il totale del costo di un cammino,
% considerando i vari costi per ogni azione.
% La regola è di tipo: gCosto(ListaAzioni, G_costo)

% Se la lista di azioni è vuota, il costo è zero
gCosto([], 0).

% Somma ricorsiva dei costi delle azioni applicate
gCosto([Azione|AltreAzioni], G_costo_totale):-
    gCosto(AltreAzioni, G_costo_parziale),
    costo(Azione, G_costo),
    G_costo_totale is G_costo_parziale + G_costo.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% CALCOLO DELLA MIGLIORE USCITA IN BASE ALL'EURISTICA
% Regole per trovare l'uscita più vicina in base alla euristica.
% La migliore uscita è quella con l'euristica più piccola.
% La regola è di tipo: miglioreUscita_aux(StatoAttuale, DistanzaMigliore)
miglioreUscita(Attuale, HMigliore):-
  % Trova tutte le uscite possibili
  findall(Finale, finale(Finale), ListaUscite),
  miglioreUscita_aux(Attuale, ListaUscite, HMigliore).

% La regola è di tipo: miglioreUscita_aux(StatoAttuale, ListaUscite, DistanzaMigliore)
% Passo base: l'uscita migliore è l'unica in elenco
miglioreUscita_aux(Attuale, [UscitaCorrente], H):-
  euristica(Attuale, UscitaCorrente, H).

% Passo ricorsivo: per ogni possibile uscita cerco quella con euristica minore e
% aggiorno il minimo
% Caso 1: se la distanza corrente è minore di quella già registrata
miglioreUscita_aux(Attuale, [UscitaCorrente|RestoUscite], DistCorrente):-
  miglioreUscita_aux(Attuale, RestoUscite, HMiglioreParziale),
  euristica(Attuale, UscitaCorrente, DistCorrente),
  DistCorrente < HMiglioreParziale.
% Caso 2: se la distanza corrente è maggiore di quella già registrata
miglioreUscita_aux(Attuale, [UscitaCorrente|RestoUscite], HMiglioreParziale):-
  miglioreUscita_aux(Attuale, RestoUscite, HMiglioreParziale),
  euristica(Attuale, UscitaCorrente, DistCorrente),
  DistCorrente >= HMiglioreParziale.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% EURISTICA: Distanza di Manhattan
% La regola è di tipo: euristica(Nodo1, Nodo2, Risultato)
euristica(pos(Riga1, Colonna1), pos(Riga2, Colonna2), H) :-
  H is abs(Riga1-Riga2) + abs(Colonna1-Colonna2).
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% AGGIORNA MINIMO FCOSTI
% Aggiorna il minimo tra due FCosto.
aggiorna_fc_min(FCosto):-
  fc_min(FMin),
  FCosto<FMin,
  retract(fc_min(FMin)),
  assert(fc_min(FCosto)).
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% IDA*
%-------------------------------------------------------------------------------
% Passo 1: inizio dell'algoritmo
% La regola è di tipo: ida(Soluzione)
ida_star(SoluzioneOrdinata):-
  % prendo il nodo di partenza
  iniziale(S_Iniziale),
  % fisso la soglia iniziale grazie all'euristica
  miglioreUscita(S_Iniziale, SogliaIniziale),
  % il primo fCost è fissato al massimo delle caselle disponibili nel labirinto considerato;
  % asserisco il fatto per mantenerlo in memoria in caso di fallimento.
  num_righe(NR),
  num_colonne(NC),
  FCMax is NR * NC,
  assert(fc_min(FCMax)),
  % la gestione dell'algoritmo passa alla seguente regola:
  limit_search_ida(Soluzione, SogliaIniziale, S_Iniziale),
  % riordino la lista delle azioni fatte in modo tale da ottenere la soluzione finale ordinata
  reverse(SoluzioneOrdinata, Soluzione),
  % quando ho trovato la soluzione, stampa il costo del cammino.
  gCosto(Soluzione, CostoCammino),
  write(CostoCammino).

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% La regola è di tipo: nomeRegola(Soluzione, Soglia, StatoIniziale)
% Per questa regola vi sono due casi:
% Primo caso: continuo l'iterazione senza cambiare la soglia
limit_search_ida(Soluzione, Soglia, S_Attuale):-
  ida_aux(node(S_Attuale, [], Soglia), Soluzione, [S_Attuale], Soglia).

% Secondo caso: non ho più percorsi con la soglia iniziale,
% allora aggiorno la soglia in base all' FCosto
limit_search_ida(Soluzione, Soglia, S_Attuale):-
  % prendo la nuova Soglia
  fc_min(NuovaSoglia),
  % ritraggo il fatto precedentemente asserito sul valore della soglia
  retract(fc_min(NuovaSoglia)),
  % calcolo il massimo FCosto possibile
  num_righe(NR),
  num_colonne(NC),
  FCMax is NR * NC,
  % asserisco nuovamente il valore dell'FCosto massimo in base
  % al numero di righe e colonne
  % questo poichè l'lgoritmo deve ripartire con un nuovo percordo
  assert(fc_min(FCMax)),
  % controllo che la soglia impostata non sia quella precedente
  \+NuovaSoglia = Soglia,
  % rilancio l'algoritmo
  limit_search_ida(Soluzione, NuovaSoglia, S_Attuale).

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% La regola è di tipo ida_aux(Nodo con ListaAzioni e FCosto, Lista delle azioni
% che portano alla soluzione finale, Lista dei nodi visitati, Soglia)
% Anche qui differenziamo più casi:
% Caso 1 (banale): il nodo corrente è il nodo Finale
% quindi la lista delle azioni diventa la soluzione.
ida_aux(node(S_Attuale, Azioni, _), Azioni, _, _):-
  finale(S_Attuale).

% Caso 2: FCosto è minore o uguale alla solglia data.
% Bisogna quindi espandere il nodo e cercare i suoi nodi figli
%(ovvero calcolare un' azione applicabile e di conseguenza il nuovo stato ).
% Per ogni figlio trovato bisogna calcolare FCosto.
ida_aux(node(S_Attuale, Azioni, FCosto), Soluzione, Visitati, Soglia):-
  % confronto soglia-costo
  FCosto =< Soglia,
  %trovo la nuova azione
  applicabile(NuovaAzione, S_Attuale),
  % mi muovo nel nuovo stato
  muovi(NuovaAzione, S_Attuale, S_Nuovo),
  % controllo che non l'abbia già visitato
  \+member(S_Nuovo, Visitati),
  % calcolo l'FCosto del nodo
  miglioreUscita(S_Attuale, H_Costo),
  % calcolo costo Cammino
  gCosto([NuovaAzione|Azioni], G_Costo),
  % cacolo FCosto
  FCostoNuovo is H_Costo + G_Costo,
  ida_aux(node(S_Nuovo, [NuovaAzione|Azioni], FCostoNuovo), Soluzione, [S_Nuovo|Visitati], Soglia).

% Caso 3: FCosto è maggiore rispetto la soglia data.
% in questo caso bisogna aggiornare FCosto minimo e controllare che sia la soluzione finale.
% Se abbiamo trovato la soluzione finale, l'algoritmo torna indietro e
% restituisce la lista delle azioni che lo hanno portato allo stato Finale;
% altrimenti fallisce e torna indietro con la nuova soglia.
ida_aux(node(S_Attuale, Azioni, FCosto), Azioni, _, Soglia):-
  % confronto soglia-costo
  FCosto > Soglia,
  %aggiorno l'FC minimo
  aggiorna_fc_min(FCosto),
  % o fallisce o ha trovato la soluzione
  finale(S_Attuale).
