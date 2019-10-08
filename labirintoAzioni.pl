% Controllo su azioni
applicabile(est, pos(Riga, Colonna)):-
  % Controlliamo di non essere sul bordo destro del labirinto
  num_colonne(NC), % Inserisce in NC il numero delle colonne
  Colonna < NC,
  % Controlliamo che la casella a est non sia occupata
  NuovaColonna is Colonna + 1,
  \+occupato(pos(Riga, NuovaColonna)).

applicabile(sud, pos(Riga, Colonna)):-
  % Controlliamo di non essere sul bordo inferiore del labirinto
  num_righe(NR), % Inserisce in NR il numero delle righe
  Riga < NR,
  % Controlliamo che la casella a sud non sia occupata
  NuovaRiga is Riga + 1,
  \+occupato(pos(NuovaRiga, Colonna)).

applicabile(ovest, pos(Riga, Colonna)):-
  % Controlliamo di non essere sul bordo sinistro del labirinto
  Colonna > 1,
  % Controlliamo che la casella a ovest non sia occupata
  NuovaColonna is Colonna - 1,
  \+occupato(pos(Riga, NuovaColonna)).

applicabile(nord, pos(Riga, Colonna)):-
  % Controlliamo di non essere sul bordo superiore del labirinto
  Riga > 1,
  % Controlliamo che la casella ad est non sia occupata
  NuovaRiga is Riga + 1,
  \+occupato(pos(NuovaRiga, Colonna)).

%------------------------------------------------------------------

% Trasformazione degli stati: assumiamo che l'applicabilità delle transizioni
% sia già stata controllata.

muovi(est, pos(Riga, Colonna), pos(Riga, NuovaColonna)):-
  NuovaColonna is Colonna + 1.

muovi(sud, pos(Riga, Colonna), pos(NuovaRiga, Colonna)):-
  NuovaRiga is Riga + 1.

muovi(ovest, pos(Riga, Colonna), pos(Riga, NuovaColonna)):-
  NuovaColonna is Colonna - 1.

muovi(nord, pos(Riga, Colonna), pos(NuovaRiga, Colonna)):-
  NuovaRiga is Riga - 1.
