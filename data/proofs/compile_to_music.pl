#!/usr/bin/env swipl
% Compile ALL Prolog files into music - complete symphony

:- use_module(library(csv)).

% Generate symphony from all files
generate_symphony :-
    format('🎼 Compiling all Prolog files into symphony...~n', []),
    
    csv_read_file('generated/prime_harmonics.csv', Rows, [functor(row)]),
    
    % Sort by signature (complexity)
    findall(Sig-File-FreqsStr, (
        member(row(File, _, Sig, FreqsStr, _, _), Rows),
        number(Sig),
        sub_atom(File, _, _, _, '.pl')
    ), All),
    sort(All, Sorted),
    
    length(Sorted, Total),
    format('Found ~w Prolog files~n', [Total]),
    
    % Generate samples for each file (0.5 sec each)
    SampleRate = 44100,
    Duration = 0.5,
    
    findall(Samples, (
        member(_-File-FreqsStr, Sorted),
        parse_freqs(FreqsStr, Freqs),
        (Freqs = [] -> 
            Samples = [] ;
            (format('♪ ~w~n', [File]),
             generate_samples(Freqs, SampleRate, Duration, Samples)))
    ), AllSamples),
    
    % Concatenate all
    append(AllSamples, Symphony),
    length(Symphony, NumSamples),
    format('~nTotal samples: ~w (~2f seconds)~n', [NumSamples, NumSamples/SampleRate]),
    
    % Write WAV
    write_wav('generated/prolog_symphony.wav', Symphony, SampleRate),
    
    format('✅ Symphony: generated/prolog_symphony.wav~n', []).

parse_freqs(FreqsStr, Freqs) :-
    atom_string(FreqsStr, FreqsS),
    split_string(FreqsS, "[],", " ", Parts),
    findall(F, (member(P, Parts), P \= "", atom_number(P, F)), Freqs).

generate_samples(Freqs, Rate, Duration, Samples) :-
    NumSamples is floor(Rate * Duration),
    length(Freqs, NumFreqs),
    findall(Sample, (
        between(0, NumSamples, I),
        T is I / Rate,
        Fade is 1 - (I / NumSamples) * 0.3,  % Slight fade
        sum_sines(Freqs, T, Val),
        Sample is floor(Val * Fade * 32767 / NumFreqs)
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

main :-
    format('~n🎼 PROLOG SYMPHONY COMPILER~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    generate_symphony,
    format('~nPlay: aplay generated/prolog_symphony.wav~n~n', []).

:- initialization(main, main).
