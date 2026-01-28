% schema_predicates.pl - Auto-generate predicates from parquet schemas

:- use_module(library(csv)).

% ═══════════════════════════════════════════════════════════
% SCHEMA DISCOVERY
% ═══════════════════════════════════════════════════════════

% Discover all parquet schemas
discover_schemas(Schemas) :-
    findall(schema(File, Columns), (
        member(File, [
            'generated/godel_lattice.csv',
            'generated/hecke_shards_rust.csv',
            'generated/zk_rdfa_urls.csv',
            'generated/tool_index.csv',
            'generated/prime_harmonics.csv',
            'generated/audio_features.csv'
        ]),
        exists_file(File),
        get_schema(File, Columns)
    ), Schemas).

% Get schema from CSV header
get_schema(File, Columns) :-
    csv_read_file(File, [Header|_], []),
    Header =.. [row|Columns].

% ═══════════════════════════════════════════════════════════
% AUTO-GENERATE PREDICATES
% ═══════════════════════════════════════════════════════════

% Generate predicate for each schema
generate_predicate(schema(File, Columns)) :-
    file_base_name(File, BaseName),
    atom_concat(Name, '.csv', BaseName),
    length(Columns, Arity),
    
    % Create predicate name
    format('~n% Auto-generated from ~w~n', [File]),
    format(':- dynamic ~w/~w.~n', [Name, Arity]),
    
    % Load data
    csv_read_file(File, Rows, []),
    forall(
        (member(Row, Rows), Row =.. [row|Values], length(Values, Arity)),
        (
            Fact =.. [Name|Values],
            (catch(assertz(Fact), _, true))
        )
    ),
    
    % Show count
    functor(Pred, Name, Arity),
    aggregate_all(count, call(Pred), Count),
    format('% Loaded ~w ~w facts~n', [Count, Name]).

% Generate all predicates
generate_all :-
    format('🔧 Auto-generating predicates from schemas...~n~n', []),
    discover_schemas(Schemas),
    forall(member(Schema, Schemas), generate_predicate(Schema)),
    format('~n✅ All predicates generated!~n', []).

% Show available predicates
show_predicates :-
    format('~n📋 Available Predicates:~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    discover_schemas(Schemas),
    forall(member(schema(File, Columns), Schemas), (
        file_base_name(File, BaseName),
        atom_concat(Name, '.csv', BaseName),
        length(Columns, Arity),
        format('  ~w/~w: ~w~n', [Name, Arity, Columns])
    )).

% ═══════════════════════════════════════════════════════════
% REASONING WITH AUTO-PREDICATES
% ═══════════════════════════════════════════════════════════

% Query any predicate
query_predicate(Name, Args) :-
    Pred =.. [Name|Args],
    call(Pred).

% Find all facts for predicate
all_facts(Name, Facts) :-
    findall(Fact, (
        current_predicate(Name/_),
        Fact =.. [Name|_],
        call(Fact)
    ), Facts).

% Demo
demo :-
    generate_all,
    show_predicates,
    
    format('~n🧠 Example Queries:~n', []),
    format('  ?- godel_lattice(71, Type, Path, Primes).~n', []),
    format('  ?- hecke_shards_rust(Godel, _, _, _, 29, _).~n', []),
    format('  ?- audio_features(File, RMS, _, _, _, _).~n', []),
    
    format('~n✨ Schema-driven predicates ready!~n', []).

main :- demo.
