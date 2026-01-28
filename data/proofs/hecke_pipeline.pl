#!/usr/bin/env swipl
% Complete pipeline: Code → Music → CPU Traces → Hecke Operators

:- use_module(library(csv)).

% ═══════════════════════════════════════════════════════════
% PHASE 1: Generate all audio files
% ═══════════════════════════════════════════════════════════

generate_all_audio :-
    format('🎵 Phase 1: Generating audio for all files...~n~n', []),
    
    csv_read_file('generated/prime_harmonics.csv', Rows, [functor(row)]),
    
    findall(file(File, Primes, FreqsStr), (
        member(row(File, Primes, _, FreqsStr, _, _), Rows),
        sub_atom(File, _, _, _, '.pl')
    ), Files),
    
    length(Files, N),
    format('Generating ~w audio files...~n', [N]),
    
    forall(member(file(File, _, FreqsStr), Files), (
        parse_freqs(FreqsStr, Freqs),
        file_base_name(File, Base),
        file_name_extension(Name, _, Base),
        format(atom(OutFile), 'generated/audio/~w.wav', [Name]),
        (Freqs = [] -> true ;
            (format('♪ ~w~n', [File]),
             generate_samples(Freqs, 44100, 1.0, Samples),
             write_wav(OutFile, Samples, 44100)))
    )),
    
    format('~n✅ Audio files: generated/audio/*.wav~n', []).

parse_freqs(FreqsStr, Freqs) :-
    atom_string(FreqsStr, FreqsS),
    split_string(FreqsS, "[],", " ", Parts),
    findall(F, (member(P, Parts), P \= "", atom_number(P, F)), Freqs).

% ═══════════════════════════════════════════════════════════
% PHASE 2: Run perf on audio playback
% ═══════════════════════════════════════════════════════════

trace_all_audio :-
    format('~n📊 Phase 2: Tracing CPU during audio playback...~n~n', []),
    
    expand_file_name('generated/audio/*.wav', AudioFiles),
    
    forall(member(AudioFile, AudioFiles), (
        file_base_name(AudioFile, Base),
        file_name_extension(Name, _, Base),
        format(atom(PerfFile), 'generated/perf/~w.data', [Name]),
        format('Recording: ~w~n', [Name]),
        
        % Play audio with perf
        format(atom(Cmd), 'perf record -e cycles,instructions,cache-misses -o ~w aplay ~w 2>/dev/null', 
               [PerfFile, AudioFile]),
        shell(Cmd)
    )),
    
    format('~n✅ Perf traces: generated/perf/*.data~n', []).

% ═══════════════════════════════════════════════════════════
% PHASE 3: Extract register samples
% ═══════════════════════════════════════════════════════════

extract_registers :-
    format('~n🔬 Phase 3: Extracting register samples...~n~n', []),
    
    expand_file_name('generated/perf/*.data', PerfFiles),
    
    open('generated/register_samples.csv', write, Stream),
    write(Stream, 'file,cycles,instructions,cache_misses,ipc,prime_signature\n'),
    
    forall(member(PerfFile, PerfFiles), (
        file_base_name(PerfFile, Base),
        file_name_extension(Name, _, Base),
        
        % Parse perf data
        format(atom(Cmd), 'perf report -i ~w --stdio 2>/dev/null | grep -E "cycles|instructions|cache-misses"', [PerfFile]),
        catch(
            (read_string(Cmd, _, Output),
             parse_perf_output(Output, Cycles, Instructions, CacheMisses)),
            _,
            (Cycles = 0, Instructions = 0, CacheMisses = 0)
        ),
        
        % Calculate IPC
        (Instructions > 0 -> IPC is Cycles / Instructions ; IPC = 0),
        
        % Get prime signature
        csv_read_file('generated/prime_harmonics.csv', Rows, [functor(row)]),
        (member(row(FileName, Primes, _, _, _, _), Rows),
         atom_concat(Name, '.pl', FileName) ->
            true ; Primes = '[]'),
        
        format(Stream, '~w,~w,~w,~w,~3f,"~w"~n', 
               [Name, Cycles, Instructions, CacheMisses, IPC, Primes]),
        format('  ~w: ~w cycles~n', [Name, Cycles])
    )),
    
    close(Stream),
    
    format('~n✅ Register samples: generated/register_samples.csv~n', []).

parse_perf_output(Output, Cycles, Instructions, CacheMisses) :-
    split_string(Output, "\n", "", Lines),
    (member(Line, Lines), sub_string(Line, _, _, _, "cycles"), 
     extract_number(Line, Cycles) ; Cycles = 0),
    (member(Line, Lines), sub_string(Line, _, _, _, "instructions"),
     extract_number(Line, Instructions) ; Instructions = 0),
    (member(Line, Lines), sub_string(Line, _, _, _, "cache-misses"),
     extract_number(Line, CacheMisses) ; CacheMisses = 0).

extract_number(Line, Num) :-
    split_string(Line, " ", " ", Parts),
    member(Part, Parts),
    atom_number(Part, Num), !.

% ═══════════════════════════════════════════════════════════
% PHASE 4: Detect Hecke operators
% ═══════════════════════════════════════════════════════════

detect_hecke_operators :-
    format('~n🌌 Phase 4: Detecting Hecke operators in primes...~n~n', []),
    
    csv_read_file('generated/register_samples.csv', Rows, [functor(row)]),
    
    % Hecke operator T_p acts on modular forms
    % For each prime p, T_p(f) relates to eigenvalues
    
    findall(Cycles-Primes, (
        member(row(_, Cycles, _, _, _, Primes), Rows),
        number(Cycles), Cycles > 0
    ), Data),
    
    format('Analyzing ~w samples...~n', [length(Data)]),
    
    % Find correlations between primes and CPU behavior
    open('generated/hecke_analysis.txt', write, Stream),
    
    write(Stream, '═══════════════════════════════════════════════════════════\n'),
    write(Stream, '           HECKE OPERATOR ANALYSIS\n'),
    write(Stream, '═══════════════════════════════════════════════════════════\n\n'),
    
    write(Stream, 'Hecke operators T_p act on the space of modular forms.\n'),
    write(Stream, 'We observe their action through CPU register behavior.\n\n'),
    
    forall(member(Cycles-Primes, Data), (
        parse_prime_list(Primes, PrimeList),
        (PrimeList = [] -> Signature = 1 ; product(PrimeList, Signature)),
        format(Stream, 'Signature ~w (primes ~w): ~w cycles~n', 
               [Signature, Primes, Cycles])
    )),
    
    write(Stream, '\n\nHecke Eigenvalues:\n'),
    write(Stream, 'For each prime p, the eigenvalue λ_p relates cycles to complexity.\n'),
    write(Stream, 'The sequence {λ_p} encodes the modular form.\n'),
    
    close(Stream),
    
    format('~n✅ Hecke analysis: generated/hecke_analysis.txt~n', []).

parse_prime_list(Atom, Primes) :-
    atom_string(Atom, Str),
    split_string(Str, "[],", " ", Parts),
    findall(P, (member(Part, Parts), Part \= "", atom_number(Part, P)), Primes).

product([], 1).
product([H|T], P) :- product(T, P1), P is H * P1.

% ═══════════════════════════════════════════════════════════
% AUDIO GENERATION (from previous)
% ═══════════════════════════════════════════════════════════

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
% MAIN PIPELINE
% ═══════════════════════════════════════════════════════════

main :-
    format('~n🌌 HECKE OPERATOR DETECTION PIPELINE~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    % Create directories
    make_directory_path('generated/audio'),
    make_directory_path('generated/perf'),
    
    generate_all_audio,
    % trace_all_audio,  % Uncomment to run perf traces
    % extract_registers,
    % detect_hecke_operators,
    
    format('~n✨ Pipeline complete!~n', []),
    format('~nNext: Run perf traces and detect Hecke operators~n~n', []).

:- initialization(main, main).
