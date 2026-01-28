% reason_parquet_facts.pl - Reason about parquet data as native Prolog facts

:- use_module(library(csv)).

% ═══════════════════════════════════════════════════════════
% LOAD PARQUET DATA AS FACTS
% ═══════════════════════════════════════════════════════════

:- dynamic entity/4.
:- dynamic hecke_shard/6.
:- dynamic zk_url/7.
:- dynamic tool/4.
:- dynamic harmonic/6.

% Load all data
load_all_facts :-
    format('📦 Loading parquet data as Prolog facts...~n~n', []),
    load_entities,
    load_hecke_shards,
    load_zk_urls,
    load_tools,
    load_harmonics,
    format('~n✅ All facts loaded!~n', []).

% Load Gödel lattice
load_entities :-
    csv_read_file('generated/godel_lattice.csv', Rows, []),
    retractall(entity(_, _, _, _)),
    forall(
        (member(Row, Rows), Row =.. [row|[G, T, P, Pr]], G \= 'godel'),
        assertz(entity(G, T, P, Pr))
    ),
    aggregate_all(count, entity(_, _, _, _), Count),
    format('  Entities: ~w facts~n', [Count]).

% Load Hecke shards
load_hecke_shards :-
    csv_read_file('generated/hecke_shards_rust.csv', Rows, []),
    retractall(hecke_shard(_, _, _, _, _, _)),
    forall(
        (member(Row, Rows), Row =.. [row|[G, T, P, Pr, S, E]], G \= 'godel'),
        assertz(hecke_shard(G, T, P, Pr, S, E))
    ),
    aggregate_all(count, hecke_shard(_, _, _, _, _, _), Count),
    format('  Hecke shards: ~w facts~n', [Count]).

% Load ZK URLs
load_zk_urls :-
    csv_read_file('generated/zk_rdfa_urls.csv', Rows, []),
    retractall(zk_url(_, _, _, _, _, _, _)),
    forall(
        (member(Row, Rows), Row =.. [row|[G, T, P, Pr, S, E, U]], G \= 'godel'),
        assertz(zk_url(G, T, P, Pr, S, E, U))
    ),
    aggregate_all(count, zk_url(_, _, _, _, _, _, _), Count),
    format('  ZK URLs: ~w facts~n', [Count]).

% Load tools
load_tools :-
    csv_read_file('generated/tool_index.csv', Rows, []),
    retractall(tool(_, _, _, _)),
    forall(
        (member(Row, Rows), Row =.. [row|[N, T, P, D]], N \= 'name'),
        assertz(tool(N, T, P, D))
    ),
    aggregate_all(count, tool(_, _, _, _), Count),
    format('  Tools: ~w facts~n', [Count]).

% Load harmonics
load_harmonics :-
    csv_read_file('generated/prime_harmonics.csv', Rows, []),
    retractall(harmonic(_, _, _, _, _, _)),
    forall(
        (member(Row, Rows), Row =.. [row|[F, S, P, Fr, E, H]], F \= 'file'),
        assertz(harmonic(F, S, P, Fr, E, H))
    ),
    aggregate_all(count, harmonic(_, _, _, _, _, _), Count),
    format('  Harmonics: ~w facts~n', [Count]).

% ═══════════════════════════════════════════════════════════
% REASONING QUERIES
% ═══════════════════════════════════════════════════════════

% Find entity by Gödel number
find_entity(Godel, Type, Path, Primes) :-
    entity(Godel, Type, Path, Primes).

% Find shard for entity
entity_shard(Godel, Shard) :-
    hecke_shard(Godel, _, _, _, Shard, _).

% Find ZK URL for entity
entity_url(Godel, URL) :-
    zk_url(Godel, _, _, _, _, _, URL).

% Find all entities in a shard
shard_members(Shard, Entities) :-
    findall(entity(G, T, P), hecke_shard(G, T, P, _, Shard, _), Entities).

% Find entities with specific prime
entities_with_prime(Prime, Entities) :-
    findall(entity(G, T, P), (
        entity(G, T, P, Primes),
        atom_string(Primes, PrimesStr),
        sub_string(PrimesStr, _, _, _, Prime)
    ), Entities).

% Find tool by prime signature
tool_by_prime(Prime, Tools) :-
    findall(tool(N, T), tool(N, T, Prime, _), Tools).

% Reason: Which entities resonate?
entities_resonate(G1, G2, Reason) :-
    entity(G1, _, P1, Pr1),
    entity(G2, _, P2, Pr2),
    G1 \= G2,
    Pr1 = Pr2,
    format(atom(Reason), '~w and ~w share primes ~w', [P1, P2, Pr1]).

% Reason: What can we learn from an entity?
analyze_entity(Godel) :-
    format('~n🔍 Analyzing entity ~w:~n', [Godel]),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    entity(Godel, Type, Path, Primes),
    format('Type: ~w~n', [Type]),
    format('Path: ~w~n', [Path]),
    format('Primes: ~w~n', [Primes]),
    
    entity_shard(Godel, Shard),
    format('Shard: ~w (Hecke)~n', [Shard]),
    
    entity_url(Godel, URL),
    format('URL: ~w~n', [URL]),
    
    format('~nReasoning:~n', []),
    format('  - Gödel number encodes identity~n', []),
    format('  - Prime signature determines properties~n', []),
    format('  - Hecke operator assigns shard~n', []),
    format('  - ZK URL proves authenticity~n', []).

% Show statistics
show_stats :-
    format('~n📊 Fact Statistics:~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    aggregate_all(count, entity(_, _, _, _), E),
    aggregate_all(count, hecke_shard(_, _, _, _, _, _), H),
    aggregate_all(count, zk_url(_, _, _, _, _, _, _), Z),
    aggregate_all(count, tool(_, _, _, _), T),
    aggregate_all(count, harmonic(_, _, _, _, _, _), Ha),
    Total is E + H + Z + T + Ha,
    format('  Entities: ~w~n', [E]),
    format('  Hecke shards: ~w~n', [H]),
    format('  ZK URLs: ~w~n', [Z]),
    format('  Tools: ~w~n', [T]),
    format('  Harmonics: ~w~n', [Ha]),
    format('  TOTAL: ~w facts~n', [Total]).

% Main
main :-
    load_all_facts,
    show_stats,
    format('~n📚 Example queries:~n', []),
    format('  ?- find_entity(71, Type, Path, Primes).~n', []),
    format('  ?- entity_shard(71, Shard).~n', []),
    format('  ?- shard_members(29, Entities).~n', []),
    format('  ?- analyze_entity(71).~n', []),
    format('~n✨ Parquet data is now native Prolog facts!~n', []).
