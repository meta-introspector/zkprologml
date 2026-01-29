
% Query verified facts

% Find file by Gödel number
by_godel(Godel, Path) :- file(Path, Godel, _).

% Find files in shard
by_shard(Shard, Path) :- file(Path, _, Shard).

% Count files per shard
count_shard(Shard, Count) :-
    findall(P, file(P, _, Shard), Files),
    length(Files, Count).

% Verify shard assignment
verify_shard(Path, Godel, Shard) :-
    file(Path, Godel, Shard),
    Shard =:= Godel mod 71.

% All verified files
all_verified(Paths) :-
    findall(P, file(P, _, _), Paths).

% Statistics
total_verified(Count) :-
    findall(P, file(P, _, _), Files),
    length(Files, Count).
