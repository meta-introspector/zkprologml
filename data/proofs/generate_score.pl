#!/usr/bin/env swipl
% Generate musical score visualization

:- use_module(library(csv)).

generate_score :-
    format('🎼 Generating musical score...~n~n', []),
    
    csv_read_file('generated/prime_harmonics.csv', Rows, [functor(row)]),
    
    findall(Sig-File-Emojis-Primes, (
        member(row(File, Primes, Sig, _, Emojis, _), Rows),
        number(Sig),
        sub_atom(File, _, _, _, '.pl')
    ), All),
    sort(All, Sorted),
    
    open('generated/musical_score.txt', write, Stream),
    
    write(Stream, '═══════════════════════════════════════════════════════════\n'),
    write(Stream, '           PROLOG SYMPHONY - MUSICAL SCORE\n'),
    write(Stream, '═══════════════════════════════════════════════════════════\n\n'),
    
    forall(member(Sig-File-Emojis-Primes, Sorted), (
        format(Stream, '~w  ~30s  ~w~n', [Emojis, File, Primes]),
        visualize_chord(Stream, Primes)
    )),
    
    write(Stream, '\n═══════════════════════════════════════════════════════════\n'),
    write(Stream, 'Legend: Each line = 0.5 seconds\n'),
    write(Stream, 'Vertical position = frequency (higher = higher pitch)\n'),
    write(Stream, 'Total duration: 12 seconds\n'),
    
    close(Stream),
    
    format('✅ Score: generated/musical_score.txt~n', []).

visualize_chord(Stream, PrimesAtom) :-
    atom_string(PrimesAtom, PrimesStr),
    split_string(PrimesStr, "[],", " ", Parts),
    findall(P, (member(Part, Parts), Part \= "", atom_number(Part, P)), Primes),
    
    % Map primes to staff positions (0-20)
    maplist(prime_to_position, Primes, Positions),
    
    % Draw staff
    write(Stream, '  '),
    forall(between(0, 20, Y), (
        (member(Y, Positions) -> write(Stream, '●') ; write(Stream, '·'))
    )),
    write(Stream, '\n').

prime_to_position(2, 0).
prime_to_position(3, 2).
prime_to_position(5, 4).
prime_to_position(7, 6).
prime_to_position(11, 8).
prime_to_position(13, 10).
prime_to_position(17, 12).
prime_to_position(19, 14).
prime_to_position(23, 16).
prime_to_position(29, 18).
prime_to_position(31, 20).
prime_to_position(_, 10).  % Default middle

main :-
    format('~n🎼 MUSICAL SCORE GENERATOR~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    generate_score,
    format('~nView: cat generated/musical_score.txt~n~n', []).

:- initialization(main, main).
