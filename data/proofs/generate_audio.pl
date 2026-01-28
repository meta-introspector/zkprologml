#!/usr/bin/env swipl
% Generate actual audio from prime harmonics

:- use_module(library(csv)).

% Generate WAV file from frequencies
generate_audio :-
    format('🎵 Generating audio from prime harmonics...~n', []),
    
    csv_read_file('generated/prime_harmonics.csv', Rows, [functor(row)]),
    
    % Top 10 most complex files
    findall(Sig-File-FreqsStr, (
        member(row(File, _, Sig, FreqsStr, _, _), Rows),
        number(Sig)
    ), All),
    sort(All, Sorted),
    reverse(Sorted, [Top|_]),
    Top = _-TopFile-TopFreqs,
    
    format('Generating audio for: ~w~n', [TopFile]),
    
    % Parse frequencies
    atom_string(TopFreqs, FreqsS),
    split_string(FreqsS, "[],", " ", Parts),
    findall(F, (member(P, Parts), P \= "", atom_number(P, F)), Freqs),
    
    format('Frequencies: ~w~n', [Freqs]),
    
    % Generate sine wave samples
    SampleRate = 44100,
    Duration = 2.0,
    generate_samples(Freqs, SampleRate, Duration, Samples),
    
    % Write to file
    write_wav('generated/prime_harmony.wav', Samples, SampleRate),
    
    format('✅ Audio: generated/prime_harmony.wav~n', []).

% Generate samples for multiple frequencies (chord)
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

% Write WAV file (minimal 16-bit PCM)
write_wav(File, Samples, Rate) :-
    length(Samples, NumSamples),
    DataSize is NumSamples * 2,
    FileSize is DataSize + 36,
    
    open(File, write, Stream, [type(binary)]),
    
    % RIFF header
    write_string(Stream, "RIFF"),
    write_int32(Stream, FileSize),
    write_string(Stream, "WAVE"),
    
    % fmt chunk
    write_string(Stream, "fmt "),
    write_int32(Stream, 16),
    write_int16(Stream, 1),        % PCM
    write_int16(Stream, 1),        % Mono
    write_int32(Stream, Rate),
    write_int32(Stream, Rate * 2), % Byte rate
    write_int16(Stream, 2),        % Block align
    write_int16(Stream, 16),       % Bits per sample
    
    % data chunk
    write_string(Stream, "data"),
    write_int32(Stream, DataSize),
    forall(member(S, Samples), write_int16(Stream, S)),
    
    close(Stream).

write_string(S, Str) :- atom_codes(Str, Codes), maplist(put_byte(S), Codes).
write_int16(S, N) :- Low is N /\ 0xFF, High is (N >> 8) /\ 0xFF, put_byte(S, Low), put_byte(S, High).
write_int32(S, N) :- 
    B0 is N /\ 0xFF, B1 is (N >> 8) /\ 0xFF, 
    B2 is (N >> 16) /\ 0xFF, B3 is (N >> 24) /\ 0xFF,
    put_byte(S, B0), put_byte(S, B1), put_byte(S, B2), put_byte(S, B3).

main :-
    format('~n🎵 PRIME HARMONY AUDIO GENERATOR~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    generate_audio,
    format('~nPlay: aplay generated/prime_harmony.wav~n~n', []).

:- initialization(main, main).
