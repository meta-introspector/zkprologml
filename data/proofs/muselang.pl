#!/usr/bin/env swipl
% MuseLang: Music → LLVM IR compiler
% Decode audio features back into executable code

:- use_module(library(csv)).

% ═══════════════════════════════════════════════════════════
% PRIME → LLVM INSTRUCTION MAPPING
% ═══════════════════════════════════════════════════════════

prime_llvm(2, 'alloca').     % Types/Memory allocation
prime_llvm(3, 'add').        % Operators
prime_llvm(5, 'load').       % Variables
prime_llvm(7, 'br').         % Control flow
prime_llvm(11, 'call').      % Functions
prime_llvm(13, 'getelementptr'). % Pointers
prime_llvm(17, 'store').     % Structures
prime_llvm(19, 'icmp').      % Arrays/Comparison
prime_llvm(23, 'phi').       % Memory/SSA
prime_llvm(29, 'select').    % Optimization
prime_llvm(31, 'ret').       % Output/Return
prime_llvm(37, 'mul').       % Loops
prime_llvm(41, 'and').       % Machine/Bitwise
prime_llvm(43, 'xor').       % Security
prime_llvm(47, 'shl').       % Network/Shift
prime_llvm(53, 'zext').      % Generics/Extension
prime_llvm(59, 'bitcast').   % Macros/Cast
prime_llvm(61, 'ptrtoint').  % Reflection
prime_llvm(67, 'invoke').    % Metaprogramming
prime_llvm(71, 'landingpad'). % Universe/Exception

% ═══════════════════════════════════════════════════════════
% AUDIO FEATURES → LLVM IR
% ═══════════════════════════════════════════════════════════

generate_llvm_from_audio :-
    format('🎵 Compiling audio to LLVM IR...~n~n', []),
    
    csv_read_file('generated/audio_features.csv', Rows, [functor(row)]),
    
    open('generated/muselang.ll', write, Stream),
    
    % LLVM header
    write_llvm_header(Stream),
    
    % Generate function for each audio file
    forall(member(row(File, RMS, ZC, Peak, _, PrimesStr), Rows), (
        parse_primes(PrimesStr, Primes),
        file_base_name(File, Base),
        file_name_extension(Name, _, Base),
        format('♪ Compiling ~w → LLVM~n', [Name]),
        write_llvm_function(Stream, Name, Primes, RMS, ZC, Peak)
    )),
    
    % Main function
    write_llvm_main(Stream),
    
    close(Stream),
    
    format('~n✅ LLVM IR: generated/muselang.ll~n', []).

write_llvm_header(S) :-
    write(S, '; MuseLang: Music → LLVM IR\n'),
    write(S, '; Generated from audio features\n\n'),
    write(S, 'target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"\n'),
    write(S, 'target triple = "x86_64-pc-linux-gnu"\n\n'),
    write(S, 'declare i32 @printf(i8*, ...)\n'),
    write(S, '@.str = private unnamed_addr constant [20 x i8] c"Result: %d\\0A\\00", align 1\n\n').

write_llvm_function(S, Name, Primes, RMS, ZC, Peak) :-
    format(S, '; Function from ~w (RMS=~w, ZC=~w, Peak=~w)~n', [Name, RMS, ZC, Peak]),
    format(S, 'define i32 @~w() {~n', [Name]),
    write(S, 'entry:\n'),
    
    % Generate instructions from primes
    generate_instructions(S, Primes, 0, Result),
    
    format(S, '  ret i32 ~w~n', [Result]),
    write(S, '}\n\n').

generate_instructions(_, [], Acc, Acc).
generate_instructions(S, [Prime|Rest], Acc, Result) :-
    prime_llvm(Prime, Instr),
    Reg is Acc + 1,
    
    % Generate appropriate instruction
    (Instr = 'add' ->
        format(S, '  %~w = add i32 ~w, ~w~n', [Reg, Acc, Prime]) ;
     Instr = 'mul' ->
        format(S, '  %~w = mul i32 ~w, ~w~n', [Reg, Acc, Prime]) ;
     Instr = 'alloca' ->
        format(S, '  %~w = add i32 ~w, ~w  ; alloca~n', [Reg, Acc, Prime]) ;
        format(S, '  %~w = add i32 ~w, ~w  ; ~w~n', [Reg, Acc, Prime, Instr])),
    
    generate_instructions(S, Rest, Reg, Result).

write_llvm_main(S) :-
    write(S, '; Main function - call all music functions\n'),
    write(S, 'define i32 @main() {\n'),
    write(S, 'entry:\n'),
    
    % Call a few functions
    csv_read_file('generated/audio_features.csv', Rows, [functor(row)]),
    findall(Name, (
        member(row(File, _, _, _, _, _), Rows),
        file_base_name(File, Base),
        file_name_extension(Name, _, Base)
    ), Names),
    
    take(3, Names, TopNames),
    
    forall(member(Name, TopNames), (
        format(S, '  %~w_result = call i32 @~w()~n', [Name, Name]),
        format(S, '  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str, i32 0, i32 0), i32 %~w_result)~n', [Name])
    )),
    
    write(S, '  ret i32 0\n'),
    write(S, '}\n').

parse_primes(Atom, Primes) :-
    atom_string(Atom, Str),
    split_string(Str, "[],", " ", Parts),
    findall(P, (member(Part, Parts), Part \= "", atom_number(Part, P)), Primes).

take(0, _, []) :- !.
take(_, [], []) :- !.
take(N, [H|T], [H|R]) :- N1 is N - 1, take(N1, T, R).

% ═══════════════════════════════════════════════════════════
% COMPILE AND RUN
% ═══════════════════════════════════════════════════════════

compile_and_run :-
    format('~n🔧 Compiling LLVM IR...~n', []),
    
    % Compile to object file
    shell('llc generated/muselang.ll -o generated/muselang.s 2>&1'),
    shell('gcc generated/muselang.s -o generated/muselang 2>&1'),
    
    format('~n▶️  Running compiled music...~n~n', []),
    shell('./generated/muselang'),
    
    format('~n✅ Music executed as code!~n', []).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n🎼 MUSELANG: MUSIC → LLVM COMPILER~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    generate_llvm_from_audio,
    % compile_and_run,  % Uncomment to compile and run
    
    format('~nNext: llc generated/muselang.ll && gcc muselang.s~n~n', []).

:- initialization(main, main).
