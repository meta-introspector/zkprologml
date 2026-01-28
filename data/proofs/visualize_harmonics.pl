#!/usr/bin/env swipl
% Generate harmonic visualization - ASCII art showing code as music

:- use_module(library(csv)).

visualize_harmonics :-
    format('~n🎼 PRIME HARMONIC VISUALIZATION~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    csv_read_file('generated/prime_harmonics.csv', Rows, [functor(row)]),
    
    % Find most complex files (highest signatures)
    findall(Sig-File-Emojis, (
        member(row(File, _, Sig, _, Emojis, _), Rows),
        number(Sig)
    ), All),
    sort(All, Sorted),
    reverse(Sorted, Desc),
    take(10, Desc, Top10),
    
    format('🏆 TOP 10 MOST COMPLEX (by prime signature):~n~n', []),
    forall(member(Sig-File-Emojis, Top10), (
        format('~w ~20s ~15w~n', [Emojis, File, Sig])
    )),
    
    % Find harmonic clusters (same prime sets)
    format('~n~n🎵 HARMONIC CLUSTERS (same prime signature):~n~n', []),
    findall(Primes-Files, (
        member(row(_, Primes, _, _, _, _), Rows),
        findall(F, member(row(F, Primes, _, _, _, _), Rows), Files),
        length(Files, N),
        N > 1
    ), Clusters),
    sort(Clusters, UniqueClusters),
    forall(member(Primes-Files, UniqueClusters), (
        length(Files, N),
        format('~w (~w files): ~w~n', [Primes, N, Files])
    )),
    
    % Musical scale visualization
    format('~n~n🎹 MUSICAL SCALE (frequency distribution):~n~n', []),
    findall(Freq, (
        member(row(_, _, _, FreqsStr, _, _), Rows),
        atom_string(FreqsStr, FreqsS),
        split_string(FreqsS, "[],", " ", Parts),
        member(Part, Parts),
        Part \= "",
        atom_number(Part, Freq)
    ), AllFreqs),
    histogram(AllFreqs, 10),
    
    format('~n✨ Harmonic analysis complete!~n~n', []).

take(0, _, []) :- !.
take(_, [], []) :- !.
take(N, [H|T], [H|R]) :- N1 is N - 1, take(N1, T, R).

histogram(Values, Bins) :-
    min_list(Values, Min),
    max_list(Values, Max),
    Range is Max - Min,
    BinSize is Range / Bins,
    findall(Count, (
        between(0, Bins, I),
        Low is Min + I * BinSize,
        High is Low + BinSize,
        findall(V, (member(V, Values), V >= Low, V < High), Bin),
        length(Bin, Count)
    ), Counts),
    max_list(Counts, MaxCount),
    forall(nth0(I, Counts, Count), (
        Low is Min + I * BinSize,
        Bars is floor(Count * 40 / MaxCount),
        format('~w Hz: ', [Low]),
        print_bars(Bars),
        format(' ~w~n', [Count])
    )).

print_bars(0) :- !.
print_bars(N) :- N > 0, write('█'), N1 is N - 1, print_bars(N1).

main :-
    visualize_harmonics.

:- initialization(main, main).
