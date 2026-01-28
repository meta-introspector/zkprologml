% reason_facts.pl - Parquet data as native Prolog facts

:- use_module(library(csv)).

% ═══════════════════════════════════════════════════════════
% LOAD ALL DATA AS FACTS
% ═══════════════════════════════════════════════════════════

:- dynamic entity/4.
:- dynamic shard/3.
:- dynamic url/7.

% Load on startup
:- initialization(load_all).

load_all :-
    format('📦 Loading parquet data as facts...~n', []),
    catch(load_entities, E, (format('Error loading entities: ~w~n', [E]), fail)),
    catch(load_shards, E2, (format('Error loading shards: ~w~n', [E2]), fail)),
    catch(load_urls, E3, (format('Error loading urls: ~w~n', [E3]), fail)),
    show_stats.

load_entities :-
    csv_read_file('generated/godel_lattice.csv', Rows, []),
    forall(
        (member(Row, Rows), Row =.. [row|[G, T, P, Pr]], integer(G)),
        assertz(entity(G, T, P, Pr))
    ),
    aggregate_all(count, entity(_, _, _, _), C),
    format('  ✅ ~w entities~n', [C]).

load_shards :-
    csv_read_file('generated/hecke_shards_rust.csv', Rows, []),
    forall(
        (member(Row, Rows), 
         Row =.. [row|Fields],
         length(Fields, 6),
         nth0(0, Fields, G),
         nth0(4, Fields, S),
         nth0(5, Fields, E),
         integer(G)),
        assertz(shard(G, S, E))
    ),
    aggregate_all(count, shard(_, _, _), C),
    format('  ✅ ~w shards~n', [C]).

load_urls :-
    csv_read_file('generated/zk_rdfa_urls.csv', Rows, []),
    forall(
        (member(Row, Rows), Row =.. [row|[G, T, P, Pr, S, E, U]], integer(G)),
        assertz(url(G, T, P, Pr, S, E, U))
    ),
    aggregate_all(count, url(_, _, _, _, _, _, _), C),
    format('  ✅ ~w urls~n', [C]).

show_stats :-
    aggregate_all(count, entity(_, _, _, _), E),
    aggregate_all(count, shard(_, _, _), S),
    aggregate_all(count, url(_, _, _, _, _, _, _), U),
    Total is E + S + U,
    format('~n📊 Total: ~w facts loaded~n~n', [Total]).

% ═══════════════════════════════════════════════════════════
% REASONING QUERIES
% ═══════════════════════════════════════════════════════════

% What is entity 71?
what_is(Godel) :-
    entity(Godel, Type, Path, Primes),
    shard(Godel, Shard, Eigensum),
    url(Godel, _, _, _, _, _, URL),
    format('🔍 Entity ~w:~n', [Godel]),
    format('  Type: ~w~n', [Type]),
    format('  Path: ~w~n', [Path]),
    format('  Primes: ~w~n', [Primes]),
    format('  Shard: ~w (eigensum ~w)~n', [Shard, Eigensum]),
    format('  URL: ~w~n', [URL]).

% Which entities are in shard 29?
in_shard(Shard, Entities) :-
    findall(G, shard(G, Shard, _), Entities).

% How many entities per shard?
shard_count(Shard, Count) :-
    aggregate_all(count, shard(_, Shard, _), Count).

% Which entities share primes?
share_primes(G1, G2) :-
    entity(G1, _, P1, Pr),
    entity(G2, _, P2, Pr),
    G1 < G2,
    format('~w and ~w share primes ~w~n', [P1, P2, Pr]).

% What's the largest shard?
largest_shard(Shard, Count) :-
    findall(C-S, (member(S, [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71]), shard_count(S, C)), Pairs),
    sort(Pairs, Sorted),
    reverse(Sorted, [Count-Shard|_]).

% Demo reasoning
demo :-
    format('🧠 REASONING ABOUT PARQUET FACTS~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    format('Query: what_is(71)~n', []),
    (what_is(71) -> true ; format('  Not found~n', [])),
    
    format('~nQuery: largest_shard(Shard, Count)~n', []),
    (largest_shard(Shard, Count) ->
        format('  Largest: Shard ~w with ~w entities~n', [Shard, Count])
    ;   format('  Not found~n', [])),
    
    format('~nQuery: in_shard(29, Entities)~n', []),
    (in_shard(29, Entities) ->
        (length(Entities, Len),
         format('  Shard 29 has ~w entities~n', [Len]))
    ;   format('  Not found~n', [])),
    
    format('~n✨ Parquet data is now native Prolog facts!~n', []).

main :- demo.
