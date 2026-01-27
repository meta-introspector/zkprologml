% List of Lists - All Parquet Files
% Organize parquets by category for lattice proof

:- dynamic parquet_list/2.
:- dynamic parquet_category/2.

% ═══════════════════════════════════════════════════════════
% PARQUET LISTS BY CATEGORY
% ═══════════════════════════════════════════════════════════

% Search parquets (knowledge bases)
parquet_category(search, [
    'data/parquets/monster_search.parquet',
    'data/parquets/godel_search.parquet',
    'data/parquets/kurt_search.parquet',
    'data/parquets/umberto_search.parquet',
    'data/parquets/athena_search.parquet',
    'data/parquets/urania_search.parquet',
    'data/parquets/platonic_search.parquet'
]).

% Lattice parquets (P×N×M structure)
parquet_category(lattice, [
    'data/parquets/pnm_lattice.parquet',
    'data/parquets/keywords_pnm_lattice.parquet'
]).

% All parquets (master list)
all_parquets(All) :-
    findall(List, parquet_category(_, List), Lists),
    append(Lists, All).

% ═══════════════════════════════════════════════════════════
% LIST OF LISTS STRUCTURE
% ═══════════════════════════════════════════════════════════

% List of lists: [[search_parquets], [lattice_parquets]]
parquet_lists(Lists) :-
    findall([Category, Files], parquet_category(Category, Files), Lists).

% ═══════════════════════════════════════════════════════════
% PROVE LATTICE INDEXES FROM PARQUETS
% ═══════════════════════════════════════════════════════════

prove_from_parquets :-
    write('🗂️  Proving lattice from parquet lists...'), nl,
    nl,
    
    parquet_lists(Lists),
    format('Found ~w categories:~n', [Lists]),
    
    % Process each category
    maplist(process_category, Lists).

process_category([Category, Files]) :-
    length(Files, Count),
    format('~n📊 Category: ~w (~w files)~n', [Category, Count]),
    maplist(show_file, Files).

show_file(File) :-
    format('  - ~w~n', [File]).

% ═══════════════════════════════════════════════════════════
% ORACLE: Load parquets via Rust
% ═══════════════════════════════════════════════════════════

oracle_load_parquets :-
    write('🔍 Loading parquets via Rust oracle...'), nl,
    
    all_parquets(Files),
    format('Loading ~w parquet files~n', [Files]),
    
    % Call Rust to load parquets
    shell('cargo run --bin prove_lattice_indexes', Result),
    format('Result: ~w~n', [Result]).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('📋 LIST OF LISTS - PARQUET FILES'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    prove_from_parquets,
    
    nl,
    write('✅ PARQUET LISTS COMPLETE'), nl,
    
    % Show master list
    all_parquets(All),
    length(All, Total),
    format('~n🎯 Total parquets: ~w~n', [Total]).

% ?- main.
