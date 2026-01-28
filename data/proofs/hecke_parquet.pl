% hecke_parquet.pl - Query Hecke shards from CSV in Prolog

:- use_module(library(csv)).

% Query Hecke shard from CSV
query_hecke_shard(Shard, Entities) :-
    csv_read_file('generated/hecke_shards_rust.csv', Rows, []),
    findall([G, T, P, Pr, S, E], (
        member(Row, Rows),
        Row =.. [row|[G, T, P, Pr, S, E]],
        S = Shard,
        G \= 'godel'
    ), Entities).

% Get shard for Gödel number  
godel_to_shard(Godel, Shard) :-
    csv_read_file('generated/hecke_shards_rust.csv', Rows, []),
    member(Row, Rows),
    Row =.. [row|[Godel, _, _, _, Shard, _]],
    !.

% Statistics
hecke_stats :-
    format('📊 Hecke Shard Statistics (CSV):~n', []),
    csv_read_file('generated/hecke_shards_rust.csv', Rows, []),
    forall(
        member(P, [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71]),
        (
            findall(G, (
                member(Row, Rows),
                Row =.. [row|[G, _, _, _, P, _]],
                G \= 'godel'
            ), Entities),
            length(Entities, Count),
            (Count > 0 -> 
                format('  Shard ~w: ~w entities~n', [P, Count]) ; true)
        )
    ).

% Example: ?- hecke_stats.

