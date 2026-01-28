% auto_register_tables.pl - Automatically register tables with multiple arities and lenses

:- use_module(library(csv)).

% ═══════════════════════════════════════════════════════════
% AUTO-REGISTRATION SYSTEM
% ═══════════════════════════════════════════════════════════

:- dynamic registered_table/3.  % table_name, arity, columns
:- dynamic table_lens/4.        % table_name, lens_name, arity, column_indices

% Discover and register all CSV/parquet tables
auto_register_all :-
    format('🔧 Auto-registering tables...~n~n', []),
    
    findall(File, (
        member(File, [
            'generated/godel_lattice.csv',
            'generated/hecke_shards_rust.csv',
            'generated/zk_rdfa_urls.csv',
            'generated/tool_index.csv',
            'generated/files_enriched_monster.csv',
            'generated/all_files_sharded.csv'
        ]),
        exists_file(File)
    ), Files),
    
    forall(member(F, Files), register_table(F)),
    
    format('~n✅ All tables registered!~n', []).

% Register a single table with all arities
register_table(File) :-
    % Get schema
    csv_read_file(File, [Header|_], []),
    Header =.. [row|Columns],
    length(Columns, Arity),
    
    % Extract table name
    file_base_name(File, BaseName),
    atom_concat(TableName, '.csv', BaseName),
    
    % Register full arity
    assertz(registered_table(TableName, Arity, Columns)),
    format('  ~w/~w: ~w~n', [TableName, Arity, Columns]),
    
    % Generate lenses (projections)
    generate_lenses(TableName, Columns),
    
    % Load data with arity in name
    load_table_data(File, TableName, Arity).

% Generate lenses for common access patterns
generate_lenses(TableName, Columns) :-
    length(Columns, FullArity),
    
    % Lens 1: Just first column (key)
    (FullArity >= 1 ->
        assertz(table_lens(TableName, key, 1, [0])),
        format('    Lens: ~w_key/1~n', [TableName])
    ; true),
    
    % Lens 2: First 3 columns (summary)
    (FullArity >= 3 ->
        assertz(table_lens(TableName, summary, 3, [0,1,2])),
        format('    Lens: ~w_summary/3~n', [TableName])
    ; true),
    
    % Lens 3: First 5 columns (detail)
    (FullArity >= 5 ->
        assertz(table_lens(TableName, detail, 5, [0,1,2,3,4])),
        format('    Lens: ~w_detail/5~n', [TableName])
    ; true).

% Load table data with arity in predicate name
load_table_data(File, TableName, Arity) :-
    csv_read_file(File, Rows, []),
    
    % Create dynamic predicate with arity in name
    format(atom(PredName), '~w_~w', [TableName, Arity]),
    
    % Load facts
    aggregate_all(count, (
        member(Row, Rows),
        Row =.. [row|Fields],
        length(Fields, Arity),
        Fact =.. [PredName|Fields],
        assertz(Fact)
    ), Count),
    
    format('    Loaded ~w facts~n', [Count]).

% Query with lens
query_lens(TableName, LensName, Args) :-
    table_lens(TableName, LensName, LensArity, Indices),
    registered_table(TableName, FullArity, _),
    
    % Build full predicate name
    format(atom(PredName), '~w_~w', [TableName, FullArity]),
    
    % Create full fact template
    length(FullArgs, FullArity),
    Fact =.. [PredName|FullArgs],
    
    % Query
    call(Fact),
    
    % Project to lens
    project_indices(FullArgs, Indices, Args).

project_indices(FullArgs, Indices, ProjectedArgs) :-
    findall(Arg, (
        member(Idx, Indices),
        nth0(Idx, FullArgs, Arg)
    ), ProjectedArgs).

% Show all registered tables
show_tables :-
    format('~n📋 REGISTERED TABLES~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    forall(registered_table(Name, Arity, Columns), (
        format('~w/~w~n', [Name, Arity]),
        format('  Columns: ~w~n', [Columns]),
        
        % Show lenses
        forall(table_lens(Name, LensName, LensArity, _), 
            format('  Lens: ~w_~w/~w~n', [Name, LensName, LensArity])),
        
        format('~n', [])
    )).

% Demo
demo :-
    auto_register_all,
    show_tables,
    
    format('~n🧠 Example Queries:~n', []),
    format('  ?- godel_lattice_4(Godel, Type, Path, Primes).~n', []),
    format('  ?- query_lens(godel_lattice, key, [Godel]).~n', []),
    format('  ?- query_lens(godel_lattice, summary, [G, T, P]).~n', []),
    format('~n✨ Auto-registration complete!~n', []).

main :- demo.
