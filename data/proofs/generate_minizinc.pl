#!/usr/bin/env swipl
% Generate MiniZinc model to optimize musical layout

:- use_module(library(csv)).

generate_minizinc :-
    format('🎼 Generating MiniZinc optimization model...~n', []),
    
    csv_read_file('generated/prime_harmonics.csv', Rows, [functor(row)]),
    
    findall(file(File, Sig, Primes), (
        member(row(File, Primes, Sig, _, _, _), Rows),
        number(Sig),
        sub_atom(File, _, _, _, '.pl')
    ), Files),
    
    length(Files, N),
    
    open('generated/symphony_layout.mzn', write, Stream),
    
    write_model(Stream, Files, N),
    
    close(Stream),
    
    format('✅ MiniZinc: generated/symphony_layout.mzn~n', []),
    format('Solve: minizinc symphony_layout.mzn~n', []).

write_model(S, Files, N) :-
    format(S, '% Optimize Prolog Symphony Layout~n', []),
    format(S, '% Find best ordering to minimize dissonance~n~n', []),
    
    % Parameters
    format(S, 'int: n = ~w;  % number of files~n', [N]),
    write(S, 'array[1..n] of int: complexity = ['),
    findall(Sig, member(file(_, Sig, _), Files), Sigs),
    write_array(S, Sigs),
    write(S, '];\n\n'),
    
    % Decision variables
    write(S, 'array[1..n] of var 1..n: order;  % permutation\n\n'),
    
    % Constraints
    write(S, 'constraint alldifferent(order);\n\n'),
    
    % Objective: minimize total dissonance
    write(S, '% Dissonance = sum of complexity jumps\n'),
    write(S, 'var int: total_dissonance = sum(i in 1..n-1)(\n'),
    write(S, '  abs(complexity[order[i+1]] - complexity[order[i]])\n'),
    write(S, ');\n\n'),
    
    write(S, 'solve minimize total_dissonance;\n\n'),
    
    % Output
    write(S, 'output [\n'),
    write(S, '  "Optimal order: " ++ show(order) ++ "\\n",\n'),
    write(S, '  "Total dissonance: " ++ show(total_dissonance) ++ "\\n"\n'),
    write(S, '];\n').

write_array(S, []) :- !.
write_array(S, [X]) :- !, format(S, '~w', [X]).
write_array(S, [H|T]) :- format(S, '~w, ', [H]), write_array(S, T).

main :-
    format('~n🎼 MINIZINC SYMPHONY OPTIMIZER~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    generate_minizinc,
    format('~n', []).

:- initialization(main, main).
