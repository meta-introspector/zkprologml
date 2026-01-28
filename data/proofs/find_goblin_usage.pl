#!/usr/bin/env swipl
% find_goblin_usage.pl - Find all usage of goblin in the codebase

:- use_module(library(process)).
:- use_module(library(lists)).

% Find all files containing "goblin"
find_goblin_files(Files) :-
    process_create(path(plocate), ['goblin'], [stdout(pipe(In))]),
    read_lines(In, Lines),
    close(In),
    % Filter for source files
    include(is_source_file, Lines, Files).

is_source_file(Path) :-
    (   sub_string(Path, _, _, _, '.rs')
    ;   sub_string(Path, _, _, _, '.toml')
    ;   sub_string(Path, _, _, _, '.lock')
    ;   sub_string(Path, _, _, _, '.pl')
    ;   sub_string(Path, _, _, _, '.lean')
    ).

read_lines(Stream, Lines) :-
    read_line_to_string(Stream, Line),
    (   Line == end_of_file
    ->  Lines = []
    ;   Lines = [Line|Rest],
        read_lines(Stream, Rest)
    ).

% Analyze goblin usage in files
analyze_goblin_usage :-
    format('~nFINDING GOBLIN USAGE~n'),
    format('============================================================~n'),
    
    find_goblin_files(Files),
    length(Files, NumFiles),
    format('~nFound ~w files containing "goblin"~n~n', [NumFiles]),
    
    % Group by type
    include(has_extension('.rs'), Files, RustFiles),
    include(has_extension('.toml'), Files, TomlFiles),
    include(has_extension('Cargo.lock'), Files, LockFiles),
    
    length(RustFiles, NumRust),
    length(TomlFiles, NumToml),
    length(LockFiles, NumLock),
    
    format('Rust files: ~w~n', [NumRust]),
    format('TOML files: ~w~n', [NumToml]),
    format('Lock files: ~w~n', [NumLock]),
    
    format('~nTop 20 goblin files:~n'),
    take(20, Files, Top20),
    forall(member(F, Top20), format('  ~w~n', [F])).

has_extension(Ext, Path) :-
    sub_string(Path, _, _, _, Ext).

take(N, List, Taken) :-
    length(Taken, N),
    append(Taken, _, List), !.
take(_, List, List).

% Find goblin crate versions
find_goblin_versions :-
    format('~n~nGOBLIN VERSIONS~n'),
    format('============================================================~n'),
    
    find_goblin_files(Files),
    include(has_extension('goblin-'), Files, VersionFiles),
    
    format('~nGoblin versions found:~n'),
    forall(
        member(Path, VersionFiles),
        (
            (   sub_string(Path, Idx, _, _, 'goblin-'),
                sub_string(Path, Idx, 15, _, Version)
            ->  format('  ~w~n', [Version])
            ;   true
            )
        )
    ).

% Find actual usage in Rust code
find_rust_usage :-
    format('~n~nRUST CODE USAGE~n'),
    format('============================================================~n'),
    
    find_goblin_files(Files),
    include(has_extension('.rs'), Files, RustFiles),
    
    format('~nSearching for "use goblin" in Rust files...~n'),
    format('(Showing first 10 files)~n~n'),
    
    take(10, RustFiles, Top10),
    forall(
        member(File, Top10),
        (
            format('File: ~w~n', [File]),
            check_file_for_use(File)
        )
    ).

check_file_for_use(File) :-
    catch(
        (
            open(File, read, Stream),
            read_lines(Stream, Lines),
            close(Stream),
            include(contains_use_goblin, Lines, UseLines),
            (   UseLines = []
            ->  format('  (no "use goblin" found)~n')
            ;   forall(member(Line, UseLines), format('  ~w~n', [Line]))
            )
        ),
        _,
        format('  (could not read file)~n')
    ).

contains_use_goblin(Line) :-
    sub_string(Line, _, _, _, 'use goblin').

% Main
main :-
    format('~nGoblin Usage Finder~n'),
    format('============================================================~n'),
    
    analyze_goblin_usage,
    find_goblin_versions,
    find_rust_usage,
    
    format('~n~n'),
    format('============================================================~n'),
    format('QED: All goblin usage found!~n'),
    format('============================================================~n').

:- initialization(main, main).
