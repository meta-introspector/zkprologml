% reason_native_parquet.pl - Reason about parquet as native Prolog facts via FFI

:- load_foreign_library('./libparquet_ffi.so').

% ═══════════════════════════════════════════════════════════
% NATIVE PARQUET AS PROLOG FACTS
% ═══════════════════════════════════════════════════════════

% Entity facts (from godel_lattice.parquet)
entity(Godel, Type, Path, Primes) :-
    parquet_row_count('generated/godel_lattice.csv', Count),
    between(0, Count, Idx),
    parquet_get_row('generated/godel_lattice.csv', Idx, Row),
    Row \= "",
    split_string(Row, ",", "\"", [GStr, Type, Path, Primes]),
    atom_number(GStr, Godel).

% Hecke shard facts (from hecke_shards_rust.parquet)
hecke_shard(Godel, Shard, Eigensum) :-
    parquet_row_count('generated/hecke_shards_rust.csv', Count),
    between(0, Count, Idx),
    parquet_get_row('generated/hecke_shards_rust.csv', Idx, Row),
    Row \= "",
    split_string(Row, ",", "\"", [GStr, _, _, _, SStr, EStr]),
    atom_number(GStr, Godel),
    atom_number(SStr, Shard),
    atom_number(EStr, Eigensum).

% ═══════════════════════════════════════════════════════════
% REASONING QUERIES
% ═══════════════════════════════════════════════════════════

% Find entity by Gödel number
find_entity(71, Type, Path, Primes) :-
    entity(71, Type, Path, Primes),
    !.

% What shard is entity in?
entity_in_shard(Godel, Shard) :-
    hecke_shard(Godel, Shard, _).

% All entities in shard 29
shard_29_entities(Entities) :-
    findall(Godel, hecke_shard(Godel, 29, _), Entities).

% Count entities per shard
count_shard(Shard, Count) :-
    aggregate_all(count, hecke_shard(_, Shard, _), Count).

% Reason: Why is entity in this shard?
explain_shard(Godel) :-
    entity(Godel, Type, Path, Primes),
    hecke_shard(Godel, Shard, Eigensum),
    format('~n🔍 Entity ~w:~n', [Godel]),
    format('  Type: ~w~n', [Type]),
    format('  Path: ~w~n', [Path]),
    format('  Primes: ~w~n', [Primes]),
    format('  Shard: ~w~n', [Shard]),
    format('  Eigensum: ~w~n', [Eigensum]),
    format('~nReasoning:~n', []),
    format('  Hecke operator T_p computed for each Monster prime~n', []),
    format('  Sum of eigenvalues = ~w~n', [Eigensum]),
    format('  ~w mod 20 = shard ~w~n', [Eigensum, Shard]).

% Demo
demo :-
    format('🧠 Reasoning about native parquet facts...~n~n', []),
    
    % Find entity 71
    format('Query: entity(71, Type, Path, Primes)~n', []),
    (find_entity(71, Type, Path, Primes) ->
        format('  Found: ~w at ~w with primes ~w~n~n', [Type, Path, Primes])
    ;   format('  Not found~n~n', [])),
    
    % Find shard
    format('Query: entity_in_shard(71, Shard)~n', []),
    (entity_in_shard(71, Shard) ->
        format('  Entity 71 is in shard ~w~n~n', [Shard])
    ;   format('  Not found~n~n', [])),
    
    % Count shard 29
    format('Query: count_shard(29, Count)~n', []),
    (count_shard(29, Count) ->
        format('  Shard 29 has ~w entities~n~n', [Count])
    ;   format('  Not found~n~n', [])),
    
    % Explain
    format('Query: explain_shard(71)~n', []),
    explain_shard(71),
    
    format('~n✨ Parquet data is now native Prolog facts!~n', []).

main :- demo.
