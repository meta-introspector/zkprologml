#!/usr/bin/env swipl
% Generate LilyPond score from prime harmonics

:- use_module(library(csv)).

generate_lilypond :-
    format('🎼 Generating LilyPond score...~n', []),
    
    csv_read_file('generated/prime_harmonics.csv', Rows, [functor(row)]),
    
    findall(Sig-File-Primes-Emojis, (
        member(row(File, Primes, Sig, _, Emojis, _), Rows),
        number(Sig),
        sub_atom(File, _, _, _, '.pl')
    ), All),
    sort(All, Sorted),
    
    open('generated/prolog_symphony.ly', write, Stream),
    
    write_header(Stream),
    write_score(Stream, Sorted),
    write_footer(Stream),
    
    close(Stream),
    
    format('✅ LilyPond: generated/prolog_symphony.ly~n', []),
    format('Compile: lilypond generated/prolog_symphony.ly~n', []).

write_header(S) :-
    write(S, '\\version "2.24.0"\n\n'),
    write(S, '\\header {\n'),
    write(S, '  title = "Prolog Symphony"\n'),
    write(S, '  subtitle = "Prime Complexity as Music"\n'),
    write(S, '  composer = "zkPrologML"\n'),
    write(S, '}\n\n'),
    write(S, '\\score {\n'),
    write(S, '  \\new Staff {\n'),
    write(S, '    \\clef treble\n'),
    write(S, '    \\time 4/4\n'),
    write(S, '    {\n').

write_score(S, Files) :-
    forall(member(_-File-Primes-Emojis, Files), (
        format(S, '      % ~w ~w~n', [File, Emojis]),
        write_chord(S, Primes)
    )).

write_chord(S, PrimesAtom) :-
    atom_string(PrimesAtom, PrimesStr),
    split_string(PrimesStr, "[],", " ", Parts),
    findall(P, (member(Part, Parts), Part \= "", atom_number(Part, P)), Primes),
    (Primes = [] -> 
        write(S, '      r2\n') ;
        (maplist(prime_to_note, Primes, Notes),
         atomic_list_concat(Notes, ' ', NotesStr),
         format(S, '      <~w>2~n', [NotesStr]))).

% Prime → LilyPond note
prime_to_note(2, 'a').
prime_to_note(3, 'b').
prime_to_note(5, 'c\'').
prime_to_note(7, 'd\'').
prime_to_note(11, 'e\'').
prime_to_note(13, 'f\'').
prime_to_note(17, 'g\'').
prime_to_note(19, 'a\'').
prime_to_note(23, 'b\'').
prime_to_note(29, 'c\'\'').
prime_to_note(31, 'd\'\'').
prime_to_note(37, 'e\'\'').
prime_to_note(41, 'f\'\'').
prime_to_note(43, 'g\'\'').
prime_to_note(47, 'a\'\'').
prime_to_note(53, 'b\'\'').
prime_to_note(59, 'c\'\'\'').
prime_to_note(61, 'd\'\'\'').
prime_to_note(67, 'e\'\'\'').
prime_to_note(71, 'f\'\'\'').
prime_to_note(_, 'c\'').

write_footer(S) :-
    write(S, '    }\n'),
    write(S, '  }\n'),
    write(S, '  \\layout { }\n'),
    write(S, '  \\midi { }\n'),
    write(S, '}\n').

main :-
    format('~n🎼 LILYPOND SCORE GENERATOR~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    generate_lilypond,
    format('~n', []).

:- initialization(main, main).
