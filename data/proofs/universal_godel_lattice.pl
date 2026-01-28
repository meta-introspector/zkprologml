#!/usr/bin/env swipl
% Universal Expert System - Everything becomes Gödel numbers in the lattice
% Tools + Parquets + Git Repos + Files + Schemas → Gödel Lattice

:- use_module(library(filesex)).

monster_primes([2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71]).

% ═══════════════════════════════════════════════════════════
% GÖDEL ENCODING
% ═══════════════════════════════════════════════════════════

% Compute Gödel number for any entity
godel_number(Entity, Godel) :-
    entity_primes(Entity, Primes),
    product(Primes, Godel).

product([], 1).
product([H|T], P) :- product(T, P1), P is H * P1.

% ═══════════════════════════════════════════════════════════
% ENTITY → PRIME MAPPING
% ═══════════════════════════════════════════════════════════

% Tools
entity_primes(tool(rust, _), [2]).
entity_primes(tool(prolog, _), [71]).
entity_primes(tool(lean4, _), [61]).
entity_primes(tool(python, _), [67]).
entity_primes(tool(nix, _), [23]).
entity_primes(tool(shell, _), [31]).

% Parquets
entity_primes(parquet(Path), Primes) :-
    (sub_atom(Path, _, _, _, 'audio') -> Primes = [19, 31] ;      % Arrays + Output
     sub_atom(Path, _, _, _, 'const') -> Primes = [2, 71] ;       % Types + Universe
     sub_atom(Path, _, _, _, 'moonshine') -> Primes = [67, 71] ;  % Meta + Universe
     sub_atom(Path, _, _, _, 'markov') -> Primes = [29, 37] ;     % Optimization + Loops
     Primes = [19]).  % Default: Arrays

% Git Repos
entity_primes(repo(Name), Primes) :-
    atom_codes(Name, Codes),
    sumlist(Codes, Sum),
    monster_primes(AllPrimes),
    length(AllPrimes, Len),
    Index is Sum mod Len,
    nth0(Index, AllPrimes, Prime),
    Primes = [Prime, 23].  % Repo prime + Memory

% Files
entity_primes(file(Path), Primes) :-
    (sub_atom(Path, _, _, _, '.rs') -> Primes = [2] ;
     sub_atom(Path, _, _, _, '.pl') -> Primes = [71] ;
     sub_atom(Path, _, _, _, '.lean') -> Primes = [61] ;
     sub_atom(Path, _, _, _, '.parquet') -> Primes = [19] ;
     sub_atom(Path, _, _, _, '.csv') -> Primes = [5, 19] ;
     sub_atom(Path, _, _, _, '.json') -> Primes = [17] ;
     Primes = [3]).  % Default: Operators

% Schemas
entity_primes(schema(Name, Columns), Primes) :-
    length(Columns, NumCols),
    monster_primes(AllPrimes),
    length(AllPrimes, Len),
    Index is NumCols mod Len,
    nth0(Index, AllPrimes, Prime),
    Primes = [Prime, 17].  % Schema prime + Structures

% ═══════════════════════════════════════════════════════════
% DISCOVER ALL ENTITIES
% ═══════════════════════════════════════════════════════════

discover_all_entities(Entities) :-
    findall(E, discover_entity(E), Entities).

discover_entity(tool(Type, Path)) :-
    member(Ext, ['.rs', '.pl', '.lean', '.py', '.nix', '.sh']),
    format(atom(Pattern), '*~w', [Ext]),
    expand_file_name(Pattern, Matches),
    member(Path, Matches),
    file_type(Path, Type).

discover_entity(parquet(Path)) :-
    expand_file_name('**/*.parquet', Matches),
    member(Path, Matches),
    exists_file(Path).

discover_entity(repo(Name)) :-
    expand_file_name('discovered_repos/*', Matches),
    member(Path, Matches),
    exists_directory(Path),
    file_base_name(Path, Name).

discover_entity(file(Path)) :-
    expand_file_name('generated/*', Matches),
    member(Path, Matches),
    exists_file(Path).

file_type(Path, Type) :-
    (sub_atom(Path, _, _, _, '.rs') -> Type = rust ;
     sub_atom(Path, _, _, _, '.pl') -> Type = prolog ;
     sub_atom(Path, _, _, _, '.lean') -> Type = lean4 ;
     sub_atom(Path, _, _, _, '.py') -> Type = python ;
     sub_atom(Path, _, _, _, '.nix') -> Type = nix ;
     sub_atom(Path, _, _, _, '.sh') -> Type = shell ;
     Type = unknown).

% ═══════════════════════════════════════════════════════════
% BUILD GÖDEL LATTICE
% ═══════════════════════════════════════════════════════════

build_godel_lattice :-
    format('🌌 Building Gödel lattice from all entities...~n~n', []),
    
    discover_all_entities(Entities),
    length(Entities, Total),
    format('Found ~w entities~n', [Total]),
    
    % Compute Gödel numbers
    findall(Godel-Entity, (
        member(Entity, Entities),
        godel_number(Entity, Godel)
    ), Lattice),
    
    % Sort by Gödel number
    sort(Lattice, SortedLattice),
    
    % Save lattice
    open('generated/godel_lattice.csv', write, S),
    write(S, 'godel,entity_type,entity_path,primes\n'),
    
    forall(member(Godel-Entity, SortedLattice), (
        entity_type_path(Entity, Type, Path),
        entity_primes(Entity, Primes),
        format(S, '~w,~w,"~w","~w"~n', [Godel, Type, Path, Primes])
    )),
    
    close(S),
    
    format('~n✅ Gödel lattice: generated/godel_lattice.csv~n', []).

entity_type_path(tool(Type, Path), tool, Path) :- !.
entity_type_path(parquet(Path), parquet, Path) :- !.
entity_type_path(repo(Name), repo, Name) :- !.
entity_type_path(file(Path), file, Path) :- !.
entity_type_path(schema(Name, _), schema, Name) :- !.
entity_type_path(_, unknown, '').

% ═══════════════════════════════════════════════════════════
% QUERY LATTICE
% ═══════════════════════════════════════════════════════════

% Find entities by Gödel number
find_by_godel(TargetGodel, Entities) :-
    discover_all_entities(AllEntities),
    findall(Entity, (
        member(Entity, AllEntities),
        godel_number(Entity, Godel),
        Godel =:= TargetGodel
    ), Entities).

% Find entities by prime signature
find_by_primes(TargetPrimes, Entities) :-
    discover_all_entities(AllEntities),
    findall(Entity, (
        member(Entity, AllEntities),
        entity_primes(Entity, Primes),
        subset(TargetPrimes, Primes)
    ), Entities).

% ═══════════════════════════════════════════════════════════
% STATISTICS
% ═══════════════════════════════════════════════════════════

lattice_statistics :-
    format('~n📊 Lattice Statistics:~n~n', []),
    
    discover_all_entities(Entities),
    
    findall(Type, (member(E, Entities), entity_type_path(E, Type, _)), Types),
    
    findall(Type-Count, (
        member(T, [tool, parquet, repo, file, schema]),
        findall(X, member(T, Types), Xs),
        length(Xs, Count),
        Type = T
    ), Stats),
    
    forall(member(Type-Count, Stats),
        format('  ~w: ~w~n', [Type, Count])),
    
    % Gödel number range
    findall(G, (member(E, Entities), godel_number(E, G)), Godels),
    (Godels = [] -> true ;
        (min_list(Godels, Min),
         max_list(Godels, Max),
         format('~nGödel range: ~w to ~w~n', [Min, Max]))).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n♾️  UNIVERSAL GÖDEL LATTICE~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    build_godel_lattice,
    lattice_statistics,
    
    format('~n✨ Everything is now a Gödel number!~n', []),
    format('~nQuery examples:~n', []),
    format('  ?- find_by_godel(71, Entities).~n', []),
    format('  ?- find_by_primes([2, 71], Entities).~n~n', []).

:- initialization(main, main).
