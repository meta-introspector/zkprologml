
is_prime(N) :- N < 2, !, fail.
is_prime(2) :- !.
is_prime(N) :- N mod 2 =:= 0, !, fail.
is_prime(N) :- is_prime_helper(N, 3).

is_prime_helper(N, I) :- I * I > N, !.
is_prime_helper(N, I) :- N mod I =:= 0, !, fail.
is_prime_helper(N, I) :- I1 is I + 2, is_prime_helper(N, I1).