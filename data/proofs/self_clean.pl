% self_clean.pl - Examine ALL hardcoded data, classify, split constants from functions

:- use_module(library(process)).

% ═══════════════════════════════════════════════════════════
% DISCOVER REAL DATA
% ═══════════════════════════════════════════════════════════

discover_repos(Repos) :-
    format('🔍 Discovering repos...~n', []),
    setup_call_cleanup(
        open(pipe('find /mnt/data1 -name ".git" -type d 2>/dev/null | head -100'), read, S),
        read_string(S, _, Output),
        close(S)
    ),
    split_string(Output, "\n", " ", Lines),
    exclude(=(""), Lines, RepoLines),
    maplist(atom_string, Repos, RepoLines),
    length(Repos, Count),
    format('  Found ~w repos~n', [Count]).

discover_files(Files) :-
    format('🔍 Discovering files...~n', []),
    setup_call_cleanup(
        open(pipe('find . -type f | head -10000'), read, S),
        read_string(S, _, Output),
        close(S)
    ),
    split_string(Output, "\n", " ", Lines),
    exclude(=(""), Lines, FileLines),
    maplist(atom_string, Files, FileLines),
    length(Files, Count),
    format('  Found ~w files~n', [Count]).

discover_parquets(Parquets) :-
    format('🔍 Discovering parquets...~n', []),
    setup_call_cleanup(
        open(pipe('find /mnt/data1 -name "*.parquet" 2>/dev/null | head -1000'), read, S),
        read_string(S, _, Output),
        close(S)
    ),
    split_string(Output, "\n", " ", Lines),
    exclude(=(""), Lines, ParquetLines),
    maplist(atom_string, Parquets, ParquetLines),
    length(Parquets, Count),
    format('  Found ~w parquets~n', [Count]).

% ═══════════════════════════════════════════════════════════
% CLASSIFY HARDCODED DATA
% ═══════════════════════════════════════════════════════════

:- dynamic constant/3.  % file, type, value
:- dynamic function/3.  % file, name, arity

classify_file(File) :-
    atom_string(File, FileStr),
    (   sub_string(FileStr, _, _, _, ".rs") -> classify_rust(File)
    ;   sub_string(FileStr, _, _, _, ".pl") -> classify_prolog(File)
    ;   sub_string(FileStr, _, _, _, ".lean") -> classify_lean(File)
    ;   true
    ).

% Classify Rust: Find constants vs functions
classify_rust(File) :-
    catch(
        (
            setup_call_cleanup(
                open(pipe(format(atom(Cmd), 'grep -E "^const |^fn " ~w 2>/dev/null', [File])), read, S),
                (
                    read_string(S, _, Content),
                    split_string(Content, "\n", " ", Lines),
                    forall(member(Line, Lines), (
                        (   sub_string(Line, _, _, _, "const ") ->
                            assertz(constant(File, rust_const, Line))
                        ;   sub_string(Line, _, _, _, "fn ") ->
                            assertz(function(File, rust_fn, Line))
                        ;   true
                        )
                    ))
                ),
                close(S)
            )
        ),
        _,
        true
    ).

% Classify Prolog: Find facts vs rules
classify_prolog(File) :-
    catch(
        (
            setup_call_cleanup(
                open(pipe(format(atom(Cmd), 'grep -E "^[a-z].*\\." ~w 2>/dev/null | head -100', [File])), read, S),
                (
                    read_string(S, _, Content),
                    split_string(Content, "\n", " ", Lines),
                    forall(member(Line, Lines), (
                        (   sub_string(Line, _, _, _, ":-") ->
                            assertz(function(File, prolog_rule, Line))
                        ;   assertz(constant(File, prolog_fact, Line))
                        )
                    ))
                ),
                close(S)
            )
        ),
        _,
        true
    ).

% Classify Lean4: Find defs vs theorems
classify_lean(File) :-
    catch(
        (
            setup_call_cleanup(
                open(pipe(format(atom(Cmd), 'grep -E "^def |^theorem " ~w 2>/dev/null', [File])), read, S),
                (
                    read_string(S, _, Content),
                    split_string(Content, "\n", " ", Lines),
                    forall(member(Line, Lines), (
                        (   sub_string(Line, _, _, _, "def ") ->
                            assertz(function(File, lean_def, Line))
                        ;   sub_string(Line, _, _, _, "theorem ") ->
                            assertz(function(File, lean_theorem, Line))
                        ;   true
                        )
                    ))
                ),
                close(S)
            )
        ),
        _,
        true
    ).

% ═══════════════════════════════════════════════════════════
% MERGE ALL CONSTANTS
% ═══════════════════════════════════════════════════════════

merge_constants :-
    format('~n🔧 Merging all constants...~n', []),
    
    findall(constant(F, T, V), constant(F, T, V), Constants),
    length(Constants, Count),
    format('  Found ~w constants~n', [Count]),
    
    % Group by type
    findall(T, constant(_, T, _), Types),
    list_to_set(Types, UniqueTypes),
    
    format('~n  Constants by type:~n', []),
    forall(member(Type, UniqueTypes), (
        aggregate_all(count, constant(_, Type, _), TypeCount),
        format('    ~w: ~w~n', [Type, TypeCount])
    )),
    
    % Save merged constants
    open('generated/merged_constants.pl', write, S),
    write(S, '% Merged constants from all files\n\n'),
    forall(constant(File, Type, Value), 
        format(S, 'merged_constant(~q, ~q, ~q).~n', [File, Type, Value])),
    close(S),
    
    format('~n  ✅ Saved to generated/merged_constants.pl~n', []).

% ═══════════════════════════════════════════════════════════
% STATISTICS
% ═══════════════════════════════════════════════════════════

show_stats :-
    format('~n📊 STATISTICS~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    aggregate_all(count, constant(_, _, _), ConstCount),
    aggregate_all(count, function(_, _, _), FuncCount),
    Total is ConstCount + FuncCount,
    
    format('  Constants: ~w~n', [ConstCount]),
    format('  Functions: ~w~n', [FuncCount]),
    format('  Total: ~w~n', [Total]),
    format('  Ratio: ~2f% constants~n', [ConstCount * 100.0 / Total]).

% ═══════════════════════════════════════════════════════════
% MAIN: SELF-CLEAN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n🧹 SELF-CLEAN: Examine ALL hardcoded data~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    % Discover real data
    discover_repos(Repos),
    discover_files(Files),
    discover_parquets(Parquets),
    
    format('~n📦 Real Data:~n', []),
    length(Repos, RepoCount),
    length(Files, FileCount),
    length(Parquets, ParquetCount),
    format('  Repos: ~w~n', [RepoCount]),
    format('  Files: ~w~n', [FileCount]),
    format('  Parquets: ~w~n', [ParquetCount]),
    
    % Classify files
    format('~n🔍 Classifying files...~n', []),
    forall(
        (member(File, Files), 
         (sub_atom(File, _, _, _, '.rs') ; 
          sub_atom(File, _, _, _, '.pl') ; 
          sub_atom(File, _, _, _, '.lean'))),
        classify_file(File)
    ),
    
    % Merge constants
    merge_constants,
    
    % Show statistics
    show_stats,
    
    format('~n✅ SELF-CLEAN COMPLETE~n', []),
    format('~nNext: Split code into constants.pl and functions.pl~n', []).
