#!/usr/bin/env swipl
% Translate compilers to LilyPond: MES → GCC → LLVM → Rustc

:- use_module(library(process)).
:- use_module(library(readutil)).

% ═══════════════════════════════════════════════════════════
% COMPILER PRIME SIGNATURES
% ═══════════════════════════════════════════════════════════

% Analyze compiler binary for prime signature
compiler_signature(mes, [2,3,5,7,11]).      % Minimal: types, ops, vars, control, functions
compiler_signature(gcc, [2,3,5,7,11,13,17,19,23,29,31]).  % Full C features
compiler_signature(llvm, [2,3,5,7,11,13,17,19,23,29,31,37,41]).  % + optimization, machine
compiler_signature(rustc, [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53]).  % + safety, traits, generics

% ═══════════════════════════════════════════════════════════
% MEASURE ACTUAL COMPILER COMPLEXITY
% ═══════════════════════════════════════════════════════════

measure_compiler(Name, Signature) :-
    format('Analyzing ~w...~n', [Name]),
    
    % Find binary
    (which_binary(Name, Path), Path \= none ->
        (size_file(Path, Size),
         format('  Binary: ~w (~w bytes)~n', [Path, Size]),
         
         % Extract features from binary
         analyze_binary(Path, Features),
         
         % Map to primes
         findall(P, (member(F, Features), feature_prime(F, P)), Primes),
         sort(Primes, Signature),
         
         format('  Primes: ~w~n', [Signature])) ;
        (compiler_signature(Name, Signature),
         format('  Using default signature: ~w~n', [Signature]))).

which_binary(mes, '/usr/bin/mes') :- exists_file('/usr/bin/mes'), !.
which_binary(gcc, Path) :- getenv('PATH', _), process_which(gcc, Path), !.
which_binary(llvm, Path) :- process_which(llc, Path), !.
which_binary(rustc, Path) :- process_which(rustc, Path), !.
which_binary(_, none).

process_which(Cmd, Path) :-
    catch(
        (process_create(path(which), [Cmd], [stdout(pipe(Out)), stderr(null)]),
         read_line_to_string(Out, PathStr),
         close(Out),
         atom_string(Path, PathStr)),
        _,
        fail).

analyze_binary(Path, Features) :-
    % Simple heuristic: larger binary = more features
    size_file(Path, Size),
    (Size < 100000 -> Features = [types, operators, variables] ;
     Size < 1000000 -> Features = [types, operators, variables, control, functions] ;
     Size < 10000000 -> Features = [types, operators, variables, control, functions, pointers, structures, arrays] ;
     Features = [types, operators, variables, control, functions, pointers, structures, arrays, memory, optimization, output]).

feature_prime(types, 2).
feature_prime(operators, 3).
feature_prime(variables, 5).
feature_prime(control, 7).
feature_prime(functions, 11).
feature_prime(pointers, 13).
feature_prime(structures, 17).
feature_prime(arrays, 19).
feature_prime(memory, 23).
feature_prime(optimization, 29).
feature_prime(output, 31).
feature_prime(loops, 37).
feature_prime(machine, 41).
feature_prime(safety, 43).
feature_prime(network, 47).
feature_prime(generics, 53).

% ═══════════════════════════════════════════════════════════
% GENERATE LILYPOND SCORE
% ═══════════════════════════════════════════════════════════

generate_compiler_score :-
    format('~n🎼 Generating compiler symphony...~n~n', []),
    
    Compilers = [mes, gcc, llvm, rustc],
    
    findall(Name-Sig, (
        member(Name, Compilers),
        measure_compiler(Name, Sig)
    ), Scores),
    
    open('generated/compiler_symphony.ly', write, Stream),
    
    write(Stream, '\\version "2.22.0"\n\n'),
    write(Stream, '\\header {\n'),
    write(Stream, '  title = "Compiler Symphony"\n'),
    write(Stream, '  subtitle = "MES → GCC → LLVM → Rustc"\n'),
    write(Stream, '  composer = "Bootstrap Chain"\n'),
    write(Stream, '}\n\n'),
    write(Stream, '\\score {\n'),
    write(Stream, '  \\new Staff {\n'),
    write(Stream, '    \\clef bass\n'),
    write(Stream, '    \\time 4/4\n'),
    write(Stream, '    {\n'),
    
    forall(member(Name-Sig, Scores), (
        format(Stream, '      % ~w~n', [Name]),
        write_compiler_chord(Stream, Sig)
    )),
    
    write(Stream, '    }\n'),
    write(Stream, '  }\n'),
    write(Stream, '  \\layout { }\n'),
    write(Stream, '  \\midi { \\tempo 4 = 60 }\n'),
    write(Stream, '}\n'),
    
    close(Stream),
    
    format('~n✅ LilyPond: generated/compiler_symphony.ly~n', []).

write_compiler_chord(S, Primes) :-
    maplist(prime_to_note, Primes, Notes),
    atomic_list_concat(Notes, ' ', NotesStr),
    format(S, '      <~w>1~n', [NotesStr]).

prime_to_note(2, 'c,').
prime_to_note(3, 'd,').
prime_to_note(5, 'e,').
prime_to_note(7, 'f,').
prime_to_note(11, 'g,').
prime_to_note(13, 'a,').
prime_to_note(17, 'b,').
prime_to_note(19, 'c').
prime_to_note(23, 'd').
prime_to_note(29, 'e').
prime_to_note(31, 'f').
prime_to_note(37, 'g').
prime_to_note(41, 'a').
prime_to_note(43, 'b').
prime_to_note(47, 'c\'').
prime_to_note(53, 'd\'').
prime_to_note(59, 'e\'').
prime_to_note(61, 'f\'').
prime_to_note(67, 'g\'').
prime_to_note(71, 'a\'').
prime_to_note(_, 'c').

% ═══════════════════════════════════════════════════════════
% GENERATE AUDIO
% ═══════════════════════════════════════════════════════════

generate_compiler_audio :-
    format('~n🎵 Generating compiler audio...~n', []),
    
    Compilers = [mes, gcc, llvm, rustc],
    
    SampleRate = 44100,
    Duration = 2.0,
    
    findall(Samples, (
        member(Name, Compilers),
        compiler_signature(Name, Primes),
        maplist(prime_frequency, Primes, Freqs),
        format('♪ ~w: ~w Hz~n', [Name, Freqs]),
        generate_samples(Freqs, SampleRate, Duration, Samples)
    ), AllSamples),
    
    append(AllSamples, Symphony),
    
    write_wav('generated/compiler_symphony.wav', Symphony, SampleRate),
    
    format('✅ Audio: generated/compiler_symphony.wav~n', []).

prime_frequency(2, 130.81).   % C3
prime_frequency(3, 146.83).   % D3
prime_frequency(5, 164.81).   % E3
prime_frequency(7, 174.61).   % F3
prime_frequency(11, 196.00).  % G3
prime_frequency(13, 220.00).  % A3
prime_frequency(17, 246.94).  % B3
prime_frequency(19, 261.63).  % C4
prime_frequency(23, 293.66).  % D4
prime_frequency(29, 329.63).  % E4
prime_frequency(31, 349.23).  % F4
prime_frequency(37, 392.00).  % G4
prime_frequency(41, 440.00).  % A4
prime_frequency(43, 493.88).  % B4
prime_frequency(47, 523.25).  % C5
prime_frequency(53, 587.33).  % D5
prime_frequency(_, 261.63).

generate_samples(Freqs, Rate, Duration, Samples) :-
    NumSamples is floor(Rate * Duration),
    length(Freqs, NumFreqs),
    findall(Sample, (
        between(0, NumSamples, I),
        T is I / Rate,
        sum_sines(Freqs, T, Val),
        Sample is floor(Val * 32767 / NumFreqs)
    ), Samples).

sum_sines([], _, 0.0).
sum_sines([F|Fs], T, Sum) :-
    sum_sines(Fs, T, Rest),
    Pi is pi,
    Sum is sin(2 * Pi * F * T) + Rest.

write_wav(File, Samples, Rate) :-
    length(Samples, NumSamples),
    DataSize is NumSamples * 2,
    FileSize is DataSize + 36,
    
    open(File, write, Stream, [type(binary)]),
    
    write_string(Stream, "RIFF"),
    write_int32(Stream, FileSize),
    write_string(Stream, "WAVE"),
    write_string(Stream, "fmt "),
    write_int32(Stream, 16),
    write_int16(Stream, 1),
    write_int16(Stream, 1),
    write_int32(Stream, Rate),
    write_int32(Stream, Rate * 2),
    write_int16(Stream, 2),
    write_int16(Stream, 16),
    write_string(Stream, "data"),
    write_int32(Stream, DataSize),
    forall(member(S, Samples), write_int16(Stream, S)),
    
    close(Stream).

write_string(S, Str) :- atom_codes(Str, Codes), maplist(put_byte(S), Codes).
write_int16(S, N) :- 
    N1 is max(-32768, min(32767, N)),
    Low is N1 /\ 0xFF, High is (N1 >> 8) /\ 0xFF, 
    put_byte(S, Low), put_byte(S, High).
write_int32(S, N) :- 
    B0 is N /\ 0xFF, B1 is (N >> 8) /\ 0xFF, 
    B2 is (N >> 16) /\ 0xFF, B3 is (N >> 24) /\ 0xFF,
    put_byte(S, B0), put_byte(S, B1), put_byte(S, B2), put_byte(S, B3).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n🎼 COMPILER SYMPHONY GENERATOR~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    generate_compiler_score,
    generate_compiler_audio,
    
    format('~n✨ Bootstrap chain as music!~n', []),
    format('MES (5 primes) → GCC (11 primes) → LLVM (13 primes) → Rustc (16 primes)~n~n', []).

:- initialization(main, main).
