% parquet_native.pl - Native parquet access via Rust FFI

:- use_foreign_library('./libparquet_ffi.so').

% Foreign predicates
:- foreign(parquet_row_count, c, parquet_row_count(+string, [-integer])).
:- foreign(parquet_get_row, c, parquet_get_row(+string, +integer, [-string])).
:- foreign(parquet_query, c, parquet_query(+string, +string, +string, [-string])).

% ═══════════════════════════════════════════════════════════
% HIGH-LEVEL INTERFACE
% ═══════════════════════════════════════════════════════════

% Count rows in parquet
parquet_count(File, Count) :-
    parquet_row_count(File, Count).

% Get specific row
parquet_row(File, Index, Row) :-
    parquet_get_row(File, Index, RowStr),
    split_string(RowStr, ",", "", Row).

% Query parquet
parquet_find(File, Column, Value, Results) :-
    parquet_query(File, Column, Value, ResultStr),
    split_string(ResultStr, "\n", "", Lines),
    maplist(split_csv, Lines, Results).

split_csv(Line, Fields) :-
    split_string(Line, ",", "", Fields).

% ═══════════════════════════════════════════════════════════
% REASONING WITH NATIVE PARQUET
% ═══════════════════════════════════════════════════════════

% Find entity by Gödel number (native)
find_entity_native(Godel, Result) :-
    atom_string(Godel, GodelStr),
    parquet_find('generated/godel_lattice.parquet', 'godel', GodelStr, Results),
    member(Result, Results).

% Find shard (native)
find_shard_native(Godel, Shard) :-
    atom_string(Godel, GodelStr),
    parquet_find('generated/hecke_shards_rust.parquet', 'godel', GodelStr, Results),
    member(Row, Results),
    nth0(4, Row, Shard).

% Example usage
demo :-
    format('🚀 Native Parquet Access Demo~n~n', []),
    
    % Count
    parquet_count('generated/godel_lattice.parquet', Count),
    format('Entities: ~w~n', [Count]),
    
    % Find entity
    find_entity_native(71, Entity),
    format('Entity 71: ~w~n', [Entity]).
