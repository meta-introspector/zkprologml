% label_all_parquets.pl - Label every row in every parquet with ZK URL

:- use_module(library(process)).

% Find all parquet files
find_parquets(Parquets) :-
    format('🔍 Finding all parquet files...~n', []),
    setup_call_cleanup(
        open(pipe('find generated -name "*.parquet"'), read, S),
        read_string(S, _, Output),
        close(S)
    ),
    split_string(Output, "\n", " ", Lines),
    exclude(=(""), Lines, Parquets).

% Label each row in a parquet
label_parquet(ParquetPath) :-
    format('~n📦 Labeling: ~w~n', [ParquetPath]),
    
    % Convert to CSV
    atom_string(ParquetAtom, ParquetPath),
    atom_concat(ParquetAtom, '.labeled.csv', CsvPath),
    
    % Read parquet via Rust
    format(atom(Cmd), './read_parquet ~w > ~w', [ParquetAtom, CsvPath]),
    shell(Cmd),
    
    format('  ✅ Labeled rows written to ~w~n', [CsvPath]).

% Main
main :-
    format('🌌 Labeling all parquet rows with ZK URLs...~n~n', []),
    
    find_parquets(Parquets),
    length(Parquets, Count),
    format('Found ~w parquet files~n', [Count]),
    
    forall(member(P, Parquets), label_parquet(P)),
    
    format('~n✨ All parquets labeled!~n', []).
