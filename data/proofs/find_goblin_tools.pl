#!/usr/bin/env swipl
% find_goblin_tools.pl - Find tools that use goblin to decode binaries

:- use_module(library(process)).
:- use_module(library(lists)).

% Read lines from stream
read_lines(Stream, Lines) :-
    read_line_to_string(Stream, Line),
    (   Line == end_of_file
    ->  Lines = []
    ;   Lines = [Line|Rest],
        read_lines(Stream, Rest)
    ).

% Find executables that might use goblin
find_goblin_tools :-
    format('~nFINDING GOBLIN-BASED TOOLS~n'),
    format('============================================================~n'),
    
    % Search for common binary analysis tools
    Tools = [
        'cargo-binutils',
        'cargo-bloat',
        'cargo-objdump',
        'cargo-nm',
        'cargo-size',
        'cargo-readobj',
        'bingrep',
        'lief',
        'readelf',
        'objdump',
        'nm'
    ],
    
    format('~nSearching for binary analysis tools...~n~n'),
    forall(
        member(Tool, Tools),
        find_tool(Tool)
    ).

find_tool(Tool) :-
    format('Searching for ~w...~n', [Tool]),
    process_create(path(plocate), [Tool], [stdout(pipe(In))]),
    read_lines(In, Lines),
    close(In),
    % Filter for executables in bin/
    include(is_executable, Lines, Execs),
    (   Execs = []
    ->  format('  Not found~n')
    ;   length(Execs, N),
        format('  Found ~w instances~n', [N]),
        take(3, Execs, Top3),
        forall(member(E, Top3), format('    ~w~n', [E]))
    ).

is_executable(Path) :-
    sub_string(Path, _, _, _, '/bin/').

take(N, List, Taken) :-
    length(Taken, N),
    append(Taken, _, List), !.
take(_, List, List).

% Find Rust projects using goblin
find_goblin_projects :-
    format('~n~nFINDING PROJECTS USING GOBLIN~n'),
    format('============================================================~n'),
    
    % Find Cargo.toml files that depend on goblin
    format('~nSearching Cargo.toml files for goblin dependency...~n'),
    process_create(path(plocate), ['Cargo.toml'], [stdout(pipe(In))]),
    read_lines(In, TomlFiles),
    close(In),
    
    % Check first 50 for goblin dependency
    take(50, TomlFiles, Sample),
    findall(
        Project,
        (
            member(File, Sample),
            check_cargo_toml(File, Project)
        ),
        Projects
    ),
    
    length(Projects, NumProjects),
    format('~nFound ~w projects using goblin:~n', [NumProjects]),
    forall(member(P, Projects), format('  ~w~n', [P])).

check_cargo_toml(File, Project) :-
    catch(
        (
            open(File, read, Stream),
            read_lines(Stream, Lines),
            close(Stream),
            member(Line, Lines),
            sub_string(Line, _, _, _, 'goblin'),
            % Extract project name from path
            split_string(File, "/", "", Parts),
            reverse(Parts, [_|RevRest]),
            reverse(RevRest, [ProjectName|_]),
            Project = ProjectName
        ),
        _,
        fail
    ).

% Find bingrep specifically (popular goblin-based tool)
find_bingrep :-
    format('~n~nFINDING BINGREP~n'),
    format('============================================================~n'),
    
    format('~nBingrep: Cross-platform binary parser using goblin~n'),
    format('Searching for bingrep...~n'),
    
    process_create(path(plocate), ['bingrep'], [stdout(pipe(In))]),
    read_lines(In, Lines),
    close(In),
    
    (   Lines = []
    ->  format('  Not installed~n'),
        format('~nInstall with: cargo install bingrep~n')
    ;   length(Lines, N),
        format('  Found ~w files~n', [N]),
        include(is_executable, Lines, Execs),
        (   Execs = []
        ->  format('  No executable found~n')
        ;   Execs = [Exec|_],
            format('  Executable: ~w~n', [Exec]),
            format('~nUsage:~n'),
            format('  bingrep <pattern> <binary>~n'),
            format('  bingrep -h  # Show help~n')
        )
    ).

% Find cargo-binutils
find_cargo_binutils :-
    format('~n~nFINDING CARGO-BINUTILS~n'),
    format('============================================================~n'),
    
    format('~nCargo-binutils: LLVM tools for Rust (may use goblin)~n'),
    
    Tools = ['cargo-objdump', 'cargo-nm', 'cargo-size', 'cargo-readobj'],
    forall(
        member(Tool, Tools),
        (
            format('~nSearching for ~w...~n', [Tool]),
            process_create(path(plocate), [Tool], [stdout(pipe(In))]),
            read_lines(In, Lines),
            close(In),
            include(is_executable, Lines, Execs),
            (   Execs = []
            ->  format('  Not found~n')
            ;   Execs = [Exec|_],
                format('  Found: ~w~n', [Exec])
            )
        )
    ).

% Check if we have goblin examples
find_goblin_examples :-
    format('~n~nFINDING GOBLIN EXAMPLES~n'),
    format('============================================================~n'),
    
    format('~nSearching for goblin example code...~n'),
    process_create(path(plocate), ['goblin'], [stdout(pipe(In))]),
    read_lines(In, Lines),
    close(In),
    
    include(is_example, Lines, Examples),
    length(Examples, N),
    format('Found ~w example files~n', [N]),
    take(10, Examples, Top10),
    forall(member(E, Top10), format('  ~w~n', [E])).

is_example(Path) :-
    (   sub_string(Path, _, _, _, '/examples/')
    ;   sub_string(Path, _, _, _, '/tests/')
    ).

% Main
main :-
    format('~nGoblin-Based Binary Decoder Tools~n'),
    format('============================================================~n'),
    
    find_goblin_tools,
    find_goblin_projects,
    find_bingrep,
    find_cargo_binutils,
    find_goblin_examples,
    
    format('~n~n'),
    format('============================================================~n'),
    format('SUMMARY: Tools that decode binaries using goblin~n'),
    format('============================================================~n'),
    format('~n1. bingrep - Cross-platform binary parser~n'),
    format('2. cargo-binutils - LLVM binary tools~n'),
    format('3. Custom projects in Cargo.toml~n'),
    format('4. Goblin examples in ~/.cargo/registry~n'),
    format('~n✅ Use these tools to decode self-similar binaries!~n'),
    format('============================================================~n').

:- initialization(main, main).
