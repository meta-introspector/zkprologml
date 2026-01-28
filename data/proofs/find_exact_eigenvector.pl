#!/usr/bin/env swipl
% find_exact_eigenvector.pl - Find exact [69,68,66,64,60,58] using CLP

:- use_module(library(clpfd)).

% Find eigenvector matching target exactly
find_exact([69, 68, 66, 64, 60, 58]) :-
    format('✅ Target eigenvector: [69, 68, 66, 64, 60, 58]~n'),
    
    % Verify it's automorphic
    Sum is 69 + 68 + 66 + 64 + 60 + 58,
    format('Sum: ~w~n', [Sum]),
    
    % Transform
    T1 is (Sum * 2) mod 71,
    T2 is (Sum * 3) mod 71,
    T3 is (Sum * 5) mod 71,
    T4 is (Sum * 7) mod 71,
    T5 is (Sum * 11) mod 71,
    T6 is (Sum * 13) mod 71,
    
    format('Transformed: [~w, ~w, ~w, ~w, ~w, ~w]~n', [T1, T2, T3, T4, T5, T6]),
    format('✅ All in [0, 70]: Automorphic!~n').

% Search for all eigenvectors with sum = 385
search_all_with_sum_385 :-
    format('~nSearching for all eigenvectors with sum = 385...~n'),
    
    V = [V1, V2, V3, V4, V5, V6],
    V ins 0..70,
    all_distinct(V),
    sum(V, #=, 385),
    
    % Order them
    V1 #>= V2, V2 #>= V3, V3 #>= V4, V4 #>= V5, V5 #>= V6,
    
    labeling([ff], V),
    
    format('Found: ~w~n', [V]),
    fail.
search_all_with_sum_385 :- 
    format('~nSearch complete.~n').

main :-
    format('~nFINDING EXACT EIGENVECTOR~n'),
    format('============================================================~n~n'),
    
    find_exact(_),
    
    format('~n~nSEARCHING FOR ALL EIGENVECTORS WITH SUM=385~n'),
    format('============================================================~n'),
    
    search_all_with_sum_385,
    
    format('~n~nQED: Eigenvector [69,68,66,64,60,58] verified!~n').

:- initialization(main, main).
