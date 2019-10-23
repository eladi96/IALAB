%-------------------------------------------------------------------------------
% Predicati per il calcolo del g costo di un Nodo
% gCosto(ListaAzioni, G_costo)
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

% Predicato per trovare l'uscita più vicina in base alla euristica.

miglioreUscita(Attuale, HMigliore):-
  % Trova tutte le uscite possibili
  findall(Finale, finale(Finale), ListaUscite),
  miglioreUscita_aux(Attuale, ListaUscite, HMigliore).

% Passo base: l'uscita migliore è l'unica in elenco
% miglioreUscita_aux(StatoAttuale, ListaUscite, UscitaMigliore)
miglioreUscita_aux(Attuale, [UscitaCorrente], H):-
  euristica(Attuale, UscitaCorrente, H).

% Passo ricorsivo
miglioreUscita_aux(Attuale, [UscitaCorrente|RestoUscite], DistCorrente):-
  miglioreUscita_aux(Attuale, RestoUscite, HMiglioreParziale),
  euristica(Attuale, UscitaCorrente, DistCorrente),
  DistCorrente < HMiglioreParziale.

% Passo ricorsivo
miglioreUscita_aux(Attuale, [UscitaCorrente|RestoUscite], HMiglioreParziale):-
  miglioreUscita_aux(Attuale, RestoUscite, HMiglioreParziale),
  euristica(Attuale, UscitaCorrente, DistCorrente),
  DistCorrente >= HMiglioreParziale.


% Euristica per IDA* (Manhattan)
euristica(pos(Riga1, Colonna1), pos(Riga2, Colonna2), H) :-
  H is abs(Riga1-Riga2) + abs(Colonna1-Colonna2).
%-------------------------------------------------------------------------------

ida(SoluzioneOrdinata):-
  % prendo il punto di partenza
  iniziale(S),
  % fisso la distanza iniziale grazie all'euristica
  miglioreUscita(S, SogliaIniziale),

  num_righe(NR),
  num_colonne(NC),
  FCMax is NR * NC,
  assert(fc_min(FCMax)),
  % inizia l'algoritmo
  appoggio(Soluzione, SogliaIniziale, S),
  reverse(SoluzioneOrdinata, Soluzione).

appoggio(Soluzione, Soglia, S):-
  ida_aux(node(S, [], Soglia), Soluzione, [S], Soglia).

appoggio(Soluzione, Soglia, S):-
  fc_min(NuovaSoglia),
  retract(fc_min(NuovaSoglia)),
  num_righe(NR),
  num_colonne(NC),
  FCMax is NR * NC,
  assert(fc_min(FCMax)),
  \+NuovaSoglia = Soglia,
  appoggio(Soluzione, NuovaSoglia, S).

ida_aux(node(S, Azioni, _), Azioni, _, _):-
  finale(S).

% nodo, Lista delle azioni che portano alla soluzione finale, soglia
ida_aux(node(S, Azioni, FCosto), Soluzione, Visitati, Soglia):-
  % confronto soglia-costo
  FCosto =< Soglia,
  %trovo la nuova azione
  applicabile(NuovaAzione, S),
  % mi muovo nel nuovo stato
  muovi(NuovaAzione, S, SNuovo),
  % controllo che non l'abbia già visitato
  \+member(SNuovo, Visitati),
  % calcolo l'FCosto del nodo
  miglioreUscita(S, Euristica),
  % calcolo costo Cammino
  gCosto([NuovaAzione|Azioni], CostoCammino),
  % cacolo FCosto
  FCostoNuovo is Euristica + CostoCammino,
  ida_aux(node(SNuovo, [NuovaAzione|Azioni], FCostoNuovo), Soluzione, [SNuovo|Visitati], Soglia).

ida_aux(node(S, Azioni, FCosto), Azioni, _, Soglia):-
  % confronto soglia-costo
  FCosto > Soglia,
  %aggiorno l'FC minimo
  aggiorna_fc_min(FCosto),
  % o fallisce o ha trovato la soluzione
  finale(S).


aggiorna_fc_min(FCosto):-
  fc_min(FMin),
  FCosto<FMin,
  retract(fc_min(FMin)),
  assert(fc_min(FCosto)).
