% index_all_parquets.pl - Index ALL parquets from lists_of_lists

:- use_module(library(process)).

meta_parquet('/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/lists_of_lists.parquet').

% Count parquets in meta index
count_parquets :-
    meta_parquet(File),
    format('🗂️  Counting parquets in: ~w~n~n', [File]),
    
    % Use DuckDB to count
    format(atom(Cmd), 'duckdb -c "SELECT COUNT(*) FROM read_parquet(\'~w\')"', [File]),
    setup_call_cleanup(
        open(pipe(Cmd), read, S),
        (read_string(S, _, Output), format('~w~n', [Output])),
        close(S)
    ).

% Get schema
show_schema :-
    meta_parquet(File),
    format('📋 Schema:~n', []),
    format(atom(Cmd), 'duckdb -c "DESCRIBE SELECT * FROM read_parquet(\'~w\')"', [File]),
    setup_call_cleanup(
        open(pipe(Cmd), read, S),
        (read_string(S, _, Output), format('~w~n', [Output])),
        close(S)
    ).

% Sample data
show_sample :-
    meta_parquet(File),
    format('📊 Sample (first 5):~n', []),
    format(atom(Cmd), 'duckdb -c "SELECT * FROM read_parquet(\'~w\') LIMIT 5"', [File]),
    setup_call_cleanup(
        open(pipe(Cmd), read, S),
        (read_string(S, _, Output), format('~w~n', [Output])),
        close(S)
    ).

main :-
    format('🌌 Indexing ALL parquets from meta index...~n~n', []),
    count_parquets,
    format('~n', []),
    show_schema,
    format('~n', []),
    show_sample.
