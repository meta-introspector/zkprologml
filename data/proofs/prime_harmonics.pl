#!/usr/bin/env swipl
% Prime Harmonics: Map every code snippet to math model, emoji, and musical harmony

:- use_module(library(readutil)).

% ═══════════════════════════════════════════════════════════
% PRIME HARMONICS - Mathematical Foundation
% ═══════════════════════════════════════════════════════════

% Prime → Frequency (Hz) mapping (A440 standard)
prime_frequency(2, 440.00).    % A4
prime_frequency(3, 493.88).    % B4
prime_frequency(5, 523.25).    % C5
prime_frequency(7, 587.33).    % D5
prime_frequency(11, 659.25).   % E5
prime_frequency(13, 698.46).   % F5
prime_frequency(17, 783.99).   % G5
prime_frequency(19, 880.00).   % A5
prime_frequency(23, 987.77).   % B5
prime_frequency(29, 1046.50).  % C6
prime_frequency(31, 1174.66).  % D6
prime_frequency(37, 1318.51).  % E6
prime_frequency(41, 1396.91).  % F6
prime_frequency(43, 1567.98).  % G6
prime_frequency(47, 1760.00).  % A6
prime_frequency(53, 1975.53).  % B6
prime_frequency(59, 2093.00).  % C7
prime_frequency(61, 2349.32).  % D7
prime_frequency(67, 2637.02).  % E7
prime_frequency(71, 2793.83).  % F7

% Prime → Emoji mapping (semantic)
prime_emoji(2, '🔢').   % Types/Numbers
prime_emoji(3, '⚡').   % Operators
prime_emoji(5, '📦').   % Variables
prime_emoji(7, '🔀').   % Control flow
prime_emoji(11, '🎯').  % Functions
prime_emoji(13, '👉').  % Pointers
prime_emoji(17, '🏗️').  % Structures
prime_emoji(19, '📊').  % Arrays
prime_emoji(23, '💾').  % Memory
prime_emoji(29, '⚙️').  % Optimization
prime_emoji(31, '📤').  % Output
prime_emoji(37, '🔄').  % Loops
prime_emoji(41, '🤖').  % Machine code
prime_emoji(43, '🔐').  % Security
prime_emoji(47, '🌐').  % Network
prime_emoji(53, '🧬').  % Generics
prime_emoji(59, '🎨').  % Macros
prime_emoji(61, '🔬').  % Reflection
prime_emoji(67, '🌌').  % Metaprogramming
prime_emoji(71, '♾️').  % Universe/Type theory

% Prime → Musical harmony (chord quality)
prime_harmony(2, 'root').
prime_harmony(3, 'major_third').
prime_harmony(5, 'perfect_fifth').
prime_harmony(7, 'minor_seventh').
prime_harmony(11, 'major_ninth').
prime_harmony(13, 'major_sixth').
prime_harmony(17, 'perfect_fourth').
prime_harmony(19, 'octave').
prime_harmony(23, 'major_second').
prime_harmony(29, 'tritone').
prime_harmony(31, 'minor_third').
prime_harmony(37, 'augmented_fifth').
prime_harmony(41, 'diminished_seventh').
prime_harmony(43, 'major_seventh').
prime_harmony(47, 'minor_ninth').
prime_harmony(53, 'augmented_fourth').
prime_harmony(59, 'minor_sixth').
prime_harmony(61, 'major_tenth').
prime_harmony(67, 'perfect_eleventh').
prime_harmony(71, 'cosmic_overtone').

% ═══════════════════════════════════════════════════════════
% CODE ANALYSIS - Extract Prime Signature
% ═══════════════════════════════════════════════════════════

% Analyze code snippet for features
code_features(Code, Features) :-
    findall(F, (
        feature_pattern(F, Pattern),
        sub_string(Code, _, _, _, Pattern)
    ), Features).

% Feature patterns (minimal)
feature_pattern(types, "int").
feature_pattern(types, "bool").
feature_pattern(types, "char").
feature_pattern(operators, "+").
feature_pattern(operators, "-").
feature_pattern(operators, "*").
feature_pattern(variables, "let").
feature_pattern(variables, "var").
feature_pattern(control, "if").
feature_pattern(control, "while").
feature_pattern(control, "for").
feature_pattern(functions, "fn").
feature_pattern(functions, "def").
feature_pattern(functions, "lambda").
feature_pattern(pointers, "*").
feature_pattern(pointers, "&").
feature_pattern(structures, "struct").
feature_pattern(arrays, "[").
feature_pattern(arrays, "]").
feature_pattern(memory, "malloc").
feature_pattern(memory, "free").
feature_pattern(output, "print").
feature_pattern(loops, "loop").
feature_pattern(machine, "asm").

% Feature → Prime mapping
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

% Code → Prime signature
code_signature(Code, Primes) :-
    code_features(Code, Features),
    findall(P, (
        member(F, Features),
        feature_prime(F, P)
    ), AllPrimes),
    sort(AllPrimes, Primes).

% ═══════════════════════════════════════════════════════════
% HARMONIC ANALYSIS
% ═══════════════════════════════════════════════════════════

% Code → Harmonic profile
code_harmonics(Code, harmonics(Primes, Freqs, Emojis, Chords, Signature)) :-
    code_signature(Code, Primes),
    maplist(prime_frequency, Primes, Freqs),
    maplist(prime_emoji, Primes, Emojis),
    maplist(prime_harmony, Primes, Chords),
    product(Primes, Signature).

product([], 1).
product([H|T], P) :- product(T, P1), P is H * P1.

% Display harmonics
display_harmonics(harmonics(Primes, Freqs, Emojis, Chords, Sig)) :-
    format('~nPrime Signature: ~w = ~w~n', [Primes, Sig]),
    format('Frequencies (Hz): ~w~n', [Freqs]),
    format('Emojis: ~w~n', [Emojis]),
    format('Harmonies: ~w~n', [Chords]).

% ═══════════════════════════════════════════════════════════
% ANALYZE ALL FILES IN V3
% ═══════════════════════════════════════════════════════════

analyze_v3_harmonics :-
    format('🎵 Analyzing prime harmonics from v3...~n', []),
    
    read_file_to_string('generated/zkprologml_v3.nw', Content, []),
    
    % Extract sample snippets
    findall(snippet(Name, Code), (
        sub_string(Content, Start, _, _, "<<"),
        sub_string(Content, Start, 100, _, Header),
        split_string(Header, "\n", "", [FirstLine|_]),
        sub_string(FirstLine, _, _, _, ">>="),
        extract_snippet_name(FirstLine, Name),
        extract_snippet_code(Content, Start, Code)
    ), Snippets),
    
    length(Snippets, N),
    format('Found ~w code snippets~n~n', [N]),
    
    % Analyze each
    open('generated/prime_harmonics.csv', write, Stream),
    write(Stream, 'file,primes,signature,frequencies,emojis,harmonies\n'),
    
    forall(member(snippet(Name, Code), Snippets), (
        code_harmonics(Code, H),
        H = harmonics(Primes, Freqs, Emojis, Chords, Sig),
        format('~w: ~w ~w~n', [Name, Emojis, Primes]),
        format(Stream, '"~w","~w",~w,"~w","~w","~w"~n', 
               [Name, Primes, Sig, Freqs, Emojis, Chords])
    )),
    
    close(Stream),
    format('~n✅ Harmonics saved to generated/prime_harmonics.csv~n', []).

extract_snippet_name(Line, Name) :-
    split_string(Line, "<>=", " ", Parts),
    member(NameStr, Parts),
    NameStr \= "",
    atom_string(Name, NameStr), !.

extract_snippet_code(Content, Start, Code) :-
    sub_string(Content, Start, 500, _, Block),
    split_string(Block, "\n", "", Lines),
    Lines = [_Header|CodeLines],
    take_until_at(CodeLines, [], RevCode),
    reverse(RevCode, Code1),
    atomic_list_concat(Code1, '\n', Code).

take_until_at([], Acc, Acc).
take_until_at([Line|_], Acc, Acc) :- sub_string(Line, 0, 1, _, "@"), !.
take_until_at([Line|Rest], Acc, Result) :- take_until_at(Rest, [Line|Acc], Result).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n🎵 PRIME HARMONICS ANALYZER~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    % Test with sample code
    format('Testing with sample code:~n', []),
    TestCode = "fn main() { let x = 42; if x > 0 { print(x); } }",
    code_harmonics(TestCode, H),
    display_harmonics(H),
    
    % Analyze v3
    format('~n~nAnalyzing complete v3 system...~n', []),
    analyze_v3_harmonics,
    
    format('~n✨ Every code snippet mapped to math, emoji, and harmony!~n~n', []).

:- initialization(main, main).
