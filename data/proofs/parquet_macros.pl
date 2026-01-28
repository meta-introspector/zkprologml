#!/usr/bin/env swipl
% Native Parquet macros for Prolog - transparent data access

:- use_module(library(process)).
:- use_module(library(readutil)).

% ═══════════════════════════════════════════════════════════
% PARQUET MACRO SYSTEM
% ═══════════════════════════════════════════════════════════

% Transparent parquet access - looks like native Prolog
:- op(1200, xfx, from_parquet).
:- op(1100, xfx, where).

% Macro: Query parquet as if it's Prolog facts
% Usage: audio_feature(File, RMS, ZC, Peak, Primes) from_parquet 'audio_features.parquet'
term_expansion((Head from_parquet ParquetFile), Clauses) :-
    % Generate predicate that reads from parquet
    Head =.. [Functor|Args],
    length(Args, Arity),
    
    % Create loader predicate
    atom_concat(Functor, '_loader', LoaderName),
    LoaderHead =.. [LoaderName],
    LoaderBody = (
        parquet_to_facts(ParquetFile, Functor, Arity)
    ),
    
    % Create query predicate
    QueryHead = Head,
    QueryBody = (
        (current_predicate(Functor/Arity) -> true ; call(LoaderHead)),
        Head
    ),
    
    Clauses = [
        (LoaderHead :- LoaderBody),
        (QueryHead :- QueryBody)
    ].

% ═══════════════════════════════════════════════════════════
% PARQUET → PROLOG CONVERTER
% ═══════════════════════════════════════════════════════════

% Convert parquet to Prolog facts (via Python)
parquet_to_facts(ParquetFile, Functor, Arity) :-
    format(atom(TempFile), '/tmp/~w_~w.pl', [Functor, Arity]),
    
    % Python script to convert parquet to Prolog
    format(atom(PythonCmd), 
        'python3 -c "import pandas as pd; df = pd.read_parquet(\'~w\'); ~
         [print(f\'~w(~w).\'.format(*tuple(map(repr, row)))) for row in df.itertuples(index=False)]" > ~w',
        [ParquetFile, Functor, '~w' * Arity, TempFile]),
    
    shell(PythonCmd),
    
    % Load generated facts
    consult(TempFile).

% ═══════════════════════════════════════════════════════════
% CSV → PARQUET CONVERTER
% ═══════════════════════════════════════════════════════════

csv_to_parquet(CSVFile, ParquetFile) :-
    format('Converting ~w → ~w~n', [CSVFile, ParquetFile]),
    
    format(atom(Cmd),
        'python3 -c "import pandas as pd; pd.read_csv(\'~w\').to_parquet(\'~w\')"',
        [CSVFile, ParquetFile]),
    
    shell(Cmd),
    
    format('✅ Parquet: ~w~n', [ParquetFile]).

% ═══════════════════════════════════════════════════════════
% EXAMPLE USAGE
% ═══════════════════════════════════════════════════════════

% Define schema - this will auto-load from parquet
audio_feature(File, RMS, ZC, Peak, Spectral, Primes) from_parquet 'generated/audio_features.parquet'.

% Query with transparent syntax
query_audio :-
    format('~n🔍 Querying parquet as Prolog facts...~n~n', []),
    
    % Find high-energy files
    findall(File-RMS, (
        audio_feature(File, RMS, _, _, _, _),
        RMS > 15000
    ), HighEnergy),
    
    format('High energy files (RMS > 15000):~n', []),
    forall(member(F-R, HighEnergy), 
        format('  ~w: ~w~n', [F, R])),
    
    % Find files with specific primes
    format('~nFiles with prime 2 and 3:~n', []),
    forall((
        audio_feature(File, _, _, _, _, Primes),
        sub_atom(Primes, _, _, _, '2'),
        sub_atom(Primes, _, _, _, '3')
    ), format('  ~w~n', [File])).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n📦 NATIVE PARQUET MACROS FOR PROLOG~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    % Convert CSV to Parquet
    (exists_file('generated/audio_features.csv') ->
        csv_to_parquet('generated/audio_features.csv', 'generated/audio_features.parquet') ;
        format('⚠️  CSV file not found~n', [])),
    
    % Query parquet transparently
    % query_audio,  % Uncomment when parquet exists
    
    format('~n✨ Parquet macros ready!~n', []),
    format('~nUsage:~n', []),
    format('  audio_feature(File, RMS, _, _, _, _) from_parquet \'file.parquet\'.~n', []),
    format('  ?- audio_feature(F, R, _, _, _, _), R > 15000.~n~n', []).

:- initialization(main, main).
