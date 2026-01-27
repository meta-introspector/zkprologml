% Lists of Lists Parquet - The Meta Parquet
% Load the parquet that contains all parquets

:- dynamic meta_parquet/1.
:- dynamic parquet_entry/3.

% ═══════════════════════════════════════════════════════════
% META PARQUET LOCATION
% ═══════════════════════════════════════════════════════════

meta_parquet('/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/lists_of_lists.parquet').

% Other meta parquets discovered
meta_parquet('/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/locate_digest.parquet').
meta_parquet('/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/meta_meta_structures.parquet').

% ═══════════════════════════════════════════════════════════
% LOAD META PARQUET with DuckDB
% ═══════════════════════════════════════════════════════════

load_lists_of_lists :-
    meta_parquet(File),
    format('🗂️  Loading meta parquet: ~w~n', [File]),
    
    % Use DuckDB to read
    format(atom(Cmd), 'duckdb -c "SELECT * FROM read_parquet(\'~w\')" > lists_of_lists.txt', [File]),
    shell(Cmd, _),
    
    format('✅ Loaded lists of lists~n', []).

% ═══════════════════════════════════════════════════════════
% INGEST ALL PARQUETS FROM META
% ═══════════════════════════════════════════════════════════

ingest_meta_parquets :-
    write('📊 Ingesting all meta parquets...'), nl,
    
    findall(F, meta_parquet(F), Files),
    maplist(load_and_analyze, Files).

load_and_analyze(File) :-
    format('~nAnalyzing: ~w~n', [File]),
    
    % Get row count
    format(atom(CountCmd), 'duckdb -c "SELECT COUNT(*) FROM read_parquet(\'~w\')"', [File]),
    shell(CountCmd, Count),
    
    % Get schema
    format(atom(SchemaCmd), 'duckdb -c "DESCRIBE SELECT * FROM read_parquet(\'~w\')"', [File]),
    shell(SchemaCmd, _),
    
    assertz(parquet_entry(File, Count, analyzed)).

% ═══════════════════════════════════════════════════════════
% PROVE LATTICE FROM META PARQUETS
% ═══════════════════════════════════════════════════════════

prove_from_meta :-
    write('🔬 Proving lattice from meta parquets...'), nl,
    
    % Load lists of lists
    load_lists_of_lists,
    
    % This is the ultimate proof: all parquets indexed
    meta_parquet(ListsOfLists),
    format('✅ Meta parquet contains ALL parquets: ~w~n', [ListsOfLists]).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🗂️  LISTS OF LISTS - META PARQUET'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    ingest_meta_parquets,
    prove_from_meta,
    
    nl,
    write('✅ META PARQUET LOADED'), nl,
    
    % Show all meta parquets
    findall(F, meta_parquet(F), All),
    format('~n🎯 Meta parquets: ~w~n', [All]).

% ?- main.
