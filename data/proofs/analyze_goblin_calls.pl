#!/usr/bin/env swipl
% analyze_goblin_calls.pl - Analyze goblin function calls and usage

:- use_module(library(process)).
:- use_module(library(lists)).

read_lines(Stream, Lines) :-
    read_line_to_string(Stream, Line),
    (   Line == end_of_file
    ->  Lines = []
    ;   Lines = [Line|Rest],
        read_lines(Stream, Rest)
    ).

% Find .rs files with goblin functions
find_goblin_rs_files(Files) :-
    process_create(path(plocate), ['goblin'], [stdout(pipe(In))]),
    read_lines(In, Lines),
    close(In),
    include(is_rs_file, Lines, Files).

is_rs_file(Path) :- sub_string(Path, _, _, _, '.rs').

% Extract functions from a Rust file
extract_functions(File, Functions) :-
    catch(
        (
            open(File, read, Stream),
            read_lines(Stream, Lines),
            close(Stream),
            findall(Func, (member(Line, Lines), extract_fn(Line, Func)), Functions)
        ),
        _,
        Functions = []
    ).

extract_fn(Line, Func) :-
    sub_string(Line, _, _, _, 'fn '),
    split_string(Line, " (", "", Parts),
    member(Part, Parts),
    sub_string(Part, _, _, _, 'fn '),
    split_string(Part, " ", "", [_, FuncName|_]),
    Func = FuncName.

% Find function calls in a file
find_calls(File, Calls) :-
    catch(
        (
            open(File, read, Stream),
            read_lines(Stream, Lines),
            close(Stream),
            findall(Call, (member(Line, Lines), extract_call(Line, Call)), Calls)
        ),
        _,
        Calls = []
    ).

extract_call(Line, Call) :-
    % Look for function calls: name(
    split_string(Line, "(", "", Parts),
    Parts = [Before|_],
    split_string(Before, " .:", "", Words),
    last(Words, Call),
    Call \= "".

% Analyze goblin source
analyze_goblin_source :-
    format('~nANALYZING GOBLIN SOURCE CODE~n'),
    format('============================================================~n'),
    
    % Find goblin lib.rs
    process_create(path(plocate), ['goblin'], [stdout(pipe(In))]),
    read_lines(In, Lines),
    close(In),
    include(is_lib_rs, Lines, LibFiles),
    
    (   LibFiles = []
    ->  format('~nNo goblin lib.rs found~n')
    ;   LibFiles = [LibFile|_],
        format('~nAnalyzing: ~w~n', [LibFile]),
        extract_functions(LibFile, Functions),
        length(Functions, NumFuncs),
        format('Found ~w functions~n', [NumFuncs]),
        take(10, Functions, Top10),
        format('~nTop 10 functions:~n'),
        forall(member(F, Top10), format('  fn ~w~n', [F]))
    ).

is_lib_rs(Path) :- sub_string(Path, _, _, _, 'lib.rs').

take(N, List, Taken) :-
    length(Taken, N),
    append(Taken, _, List), !.
take(_, List, List).

% Find callers of goblin functions
find_goblin_callers :-
    format('~n~nFINDING GOBLIN FUNCTION CALLERS~n'),
    format('============================================================~n'),
    
    % Find files that use goblin
    find_goblin_rs_files(Files),
    take(20, Files, Sample),
    
    format('~nAnalyzing ~w files for goblin usage...~n', [20]),
    
    findall(
        usage(File, Calls),
        (
            member(File, Sample),
            find_calls(File, Calls),
            Calls \= []
        ),
        Usages
    ),
    
    length(Usages, NumUsages),
    format('~nFound ~w files with function calls~n', [NumUsages]),
    
    take(5, Usages, Top5),
    forall(
        member(usage(File, Calls), Top5),
        (
            format('~nFile: ~w~n', [File]),
            take(5, Calls, TopCalls),
            format('  Calls: ~w~n', [TopCalls])
        )
    ).

% Compare source vs usage
compare_source_usage :-
    format('~n~nCOMPARING SOURCE VS USAGE~n'),
    format('============================================================~n'),
    
    % Get goblin source functions
    process_create(path(plocate), ['goblin'], [stdout(pipe(In))]),
    read_lines(In, Lines),
    close(In),
    include(is_lib_rs, Lines, LibFiles),
    
    (   LibFiles = []
    ->  format('~nNo source found~n')
    ;   LibFiles = [LibFile|_],
        extract_functions(LibFile, SourceFuncs),
        
        % Get usage
        find_goblin_rs_files(Files),
        take(10, Files, Sample),
        findall(Call, (member(F, Sample), find_calls(F, Calls), member(Call, Calls)), AllCalls),
        
        % Count occurrences
        sort(AllCalls, UniqueCalls),
        
        format('~nSource functions: ~w~n', [SourceFuncs]),
        format('~nUnique calls found: ~w~n', [UniqueCalls]),
        
        % Find overlap
        intersection(SourceFuncs, UniqueCalls, Overlap),
        length(Overlap, NumOverlap),
        format('~nOverlap (functions defined and called): ~w~n', [NumOverlap]),
        take(10, Overlap, TopOverlap),
        forall(member(O, TopOverlap), format('  ~w~n', [O]))
    ).

% Analyze cargo-binutils specifically
analyze_cargo_binutils :-
    format('~n~nANALYZING CARGO-BINUTILS~n'),
    format('============================================================~n'),
    
    % Find cargo-nm.rs
    process_create(path(plocate), ['cargo-nm.rs'], [stdout(pipe(In))]),
    read_lines(In, Lines),
    close(In),
    
    (   Lines = []
    ->  format('~nNo cargo-nm.rs found~n')
    ;   Lines = [File|_],
        format('~nAnalyzing: ~w~n', [File]),
        extract_functions(File, Functions),
        format('Functions: ~w~n', [Functions]),
        find_calls(File, Calls),
        length(Calls, NumCalls),
        format('~nTotal calls: ~w~n', [NumCalls]),
        take(20, Calls, TopCalls),
        format('~nTop 20 calls:~n'),
        forall(member(C, TopCalls), format('  ~w()~n', [C]))
    ).

% Main
main :-
    format('~nGoblin Function Call Analysis~n'),
    format('============================================================~n'),
    
    analyze_goblin_source,
    find_goblin_callers,
    compare_source_usage,
    analyze_cargo_binutils,
    
    format('~n~n'),
    format('============================================================~n'),
    format('QED: Goblin function calls analyzed!~n'),
    format('     Source functions vs usage patterns compared~n'),
    format('============================================================~n').

:- initialization(main, main).
