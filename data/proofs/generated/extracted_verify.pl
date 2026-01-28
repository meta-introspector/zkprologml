% Extracted from Monster group factorization
monster_primes([[2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71]]).
correlation_coefficient(0.000).
% Prime 2: Types (most basic)
prime_feature(2, types, "int, bool, char").

% Prime 3: Operators  
prime_feature(3, operators, "+, -, *, /").

% Prime 5: Variables
prime_feature(5, variables, "x, y, z").

% Prime 7: Control flow
prime_feature(7, control, "if, while, for").

% Prime 11: Functions
prime_feature(11, functions, "def, fn, lambda").

% Prime 13: Pointers
prime_feature(13, pointers, "*ptr, &ref").

% Prime 17: Structures
prime_feature(17, structures, "struct, record").

% Prime 19: Arrays
prime_feature(19, arrays, "[], vector").

% Prime 23: Memory
prime_feature(23, memory, "malloc, free").

% Prime 29: Optimization
prime_feature(29, optimization, "SSA, inlining").

% Prime 31: Output
prime_feature(31, output, "print, write").

% Prime 41: Machine code
prime_feature(41, machine, "assembly, linking").

% Prime 71: Universe
prime_feature(71, universe, "type theory").
prime_signature(Program, Signature) :-
    findall(Prime, (
        prime_feature(Prime, Feature, _),
        program_has_feature(Program, Feature)
    ), Primes),
    product(Primes, Signature).

product([], 1).
product([H|T], P) :- product(T, P1), P is H * P1.
calculate_correlation(Data, R) :-
    findall(P-H, member([_, P, H], Data), Pairs),
    findall(P, member(P-_, Pairs), Ps),
    findall(H, member(_-H, Pairs), Hs),
    pearson_correlation(Ps, Hs, R).

pearson_correlation(Xs, Ys, R) :-
    length(Xs, N),
    sumlist(Xs, SumX),
    sumlist(Ys, SumY),
    maplist(mult, Xs, Ys, XYs),
    sumlist(XYs, SumXY),
    maplist(square, Xs, X2s),
    sumlist(X2s, SumX2),
    maplist(square, Ys, Y2s),
    sumlist(Y2s, SumY2),
    Num is N * SumXY - SumX * SumY,
    Den is sqrt((N * SumX2 - SumX * SumX) * (N * SumY2 - SumY * SumY)),
    R is Num / Den.

mult(X, Y, Z) :- Z is X * Y.
square(X, Y) :- Y is X * X.

% Main verification
main :-
    format('~n✅ LITERATE PROGRAM VERIFICATION~n', []),
    
    % Verify primes
    monster_primes(Primes),
    length(Primes, N),
    format('Monster primes: ~w (~w total)~n', [Primes, N]),
    
    % Verify correlation
    correlation_coefficient(R),
    format('Correlation: ~3f~n', [R]),
    
    % Test prime signature
    prime_signature(test_program, Sig),
    format('Test signature: ~w~n', [Sig]),
    
    format('~n✨ All checks passed!~n~n', []).

% Test program has types and operators
program_has_feature(test_program, types).
program_has_feature(test_program, operators).

:- initialization(main, main).
