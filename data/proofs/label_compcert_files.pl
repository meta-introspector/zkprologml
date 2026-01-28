#!/usr/bin/env swipl

% Label CompCert C files with complexity
% Read actual C code, assign prime complexity to each construct

:- initialization(main, main).
:- use_module(library(readutil)).
:- use_module(library(filesex)).

:- ['c_complexity_lattice.pl'].

% ═══════════════════════════════════════════════════════════
% SCAN COMPCERT FILES
% ═══════════════════════════════════════════════════════════

scan_compcert_file(File) :-
    read_file_to_string(File, Content, []),
    
    % Count constructs
    findall(
        (Prime, Construct),
        (
            c_construct(Construct, Pattern, Prime),
            sub_string(Content, _, _, _, Pattern)
        ),
        Matches
    ),
    
    % Sum complexity
    findall(P, member((P, _), Matches), Primes),
    sum_list(Primes, TotalComplexity),
    
    length(Matches, Count),
    
    (Count > 0 ->
        format('~w: ~w constructs, complexity ~w\n', [File, Count, TotalComplexity])
    ;
        true
    ).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🔬 LABELING COMPCERT C FILES\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    CompCertPath = '/mnt/data1/2023/07/06/CompCert',
    
    % Find C files
    format('Finding C files in ~w...\n\n', [CompCertPath]),
    
    % Get first 20 files
    format(atom(Cmd), 'find ~w -name "*.c" -type f 2>/dev/null | head -20', [CompCertPath]),
    setup_call_cleanup(
        open(pipe(Cmd), read, Stream),
        (
            read_string(Stream, _, Output),
            split_string(Output, "\n", "\n", Files),
            
            write('📊 Complexity per file:\n\n'),
            forall(
                (member(File, Files), File \= ""),
                scan_compcert_file(File)
            )
        ),
        close(Stream)
    ),
    
    nl,
    write('✅ CompCert files labeled with complexity\n').
