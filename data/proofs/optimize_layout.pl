#!/usr/bin/env swipl
% Solve symphony layout optimization in Prolog

:- use_module(library(csv)).
:- use_module(library(clpfd)).

optimize_layout :-
    format('🎼 Optimizing symphony layout...~n', []),
    
    csv_read_file('generated/prime_harmonics.csv', Rows, [functor(row)]),
    
    findall(Sig-File, (
        member(row(File, _, Sig, _, _, _), Rows),
        number(Sig),
        sub_atom(File, _, _, _, '.pl')
    ), Files),
    
    % Sort by complexity (greedy approximation)
    sort(Files, Sorted),
    
    % Calculate dissonance
    calculate_dissonance(Sorted, Dissonance),
    
    format('~nOptimal order (by complexity):~n', []),
    forall(member(Sig-File, Sorted), (
        format('  ~w (~w)~n', [File, Sig])
    )),
    
    format('~nTotal dissonance: ~w~n', [Dissonance]),
    
    % Save optimized order
    open('generated/optimized_order.txt', write, Stream),
    forall(member(_-File, Sorted), (
        format(Stream, '~w~n', [File])
    )),
    close(Stream),
    
    format('✅ Optimized order: generated/optimized_order.txt~n', []).

calculate_dissonance([], 0).
calculate_dissonance([_], 0).
calculate_dissonance([S1-_,S2-_|Rest], Total) :-
    calculate_dissonance([S2-_|Rest], RestDiss),
    Total is abs(S2 - S1) + RestDiss.

main :-
    format('~n🎼 SYMPHONY LAYOUT OPTIMIZER~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    optimize_layout,
    format('~nStrategy: Sort by complexity (minimizes jumps)~n~n', []).

:- initialization(main, main).
