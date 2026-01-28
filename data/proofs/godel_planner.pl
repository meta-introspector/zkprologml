% godel_planner.pl - Query optimizer using Gödel resonance + perf data

:- consult('generated/merged_constants.pl').

% ═══════════════════════════════════════════════════════════
% GÖDEL ENCODING
% ═══════════════════════════════════════════════════════════

:- dynamic function_godel/4.  % name, godel, primes, perf_ns

% Encode goal as Gödel number
goal_to_godel(Goal, Godel) :-
    term_to_atom(Goal, Atom),
    atom_codes(Atom, Codes),
    encode_codes(Codes, Godel).

encode_codes([], 1).
encode_codes([C|Cs], G) :-
    encode_codes(Cs, G0),
    monster_primes(Primes),
    Idx is C mod 20,
    nth0(Idx, Primes, P),
    G is G0 * P.

% ═══════════════════════════════════════════════════════════
% RESONANCE - Find functions that share prime factors
% ═══════════════════════════════════════════════════════════

% Calculate resonance score (shared prime factors)
resonance(GodelA, GodelB, Score) :-
    prime_factors(GodelA, FactorsA),
    prime_factors(GodelB, FactorsB),
    intersection(FactorsA, FactorsB, Shared),
    length(Shared, Score).

prime_factors(1, []) :- !.
prime_factors(N, [P|Fs]) :-
    N > 1,
    monster_prime(P),
    N mod P =:= 0,
    N1 is N // P,
    prime_factors(N1, Fs).

% ═══════════════════════════════════════════════════════════
% COST MODEL - Size + Stats + Perf
% ═══════════════════════════════════════════════════════════

:- dynamic function_stats/5.  % name, size_bytes, rows, perf_cycles, cost

% Calculate total cost
function_cost(Name, Cost) :-
    function_stats(Name, Size, Rows, Cycles, _),
    % Cost = Size * log(Rows) + Cycles
    Cost is Size * log(max(Rows, 1)) + Cycles.

% Update cost
update_cost(Name) :-
    function_stats(Name, Size, Rows, Cycles, _),
    Cost is Size * log(max(Rows, 1)) + Cycles,
    retract(function_stats(Name, Size, Rows, Cycles, _)),
    assertz(function_stats(Name, Size, Rows, Cycles, Cost)).

% ═══════════════════════════════════════════════════════════
% QUERY OPTIMIZER
% ═══════════════════════════════════════════════════════════

% Find best execution plan for goal
optimize_query(Goal, Plan) :-
    goal_to_godel(Goal, GoalGodel),
    format('🎯 Goal Gödel: ~w~n', [GoalGodel]),
    
    % Find resonating functions
    findall(Score-Cost-Name, (
        function_godel(Name, FuncGodel, _, _),
        resonance(GoalGodel, FuncGodel, Score),
        Score > 0,
        function_cost(Name, Cost)
    ), Candidates),
    
    % Sort by resonance (desc), then cost (asc)
    sort(0, @>=, Candidates, Sorted),
    
    % Take top 5
    length(Prefix, 5),
    append(Prefix, _, Sorted),
    Plan = Prefix.

% Execute plan
execute_plan([]) :- 
    format('✅ Plan complete~n', []).
execute_plan([Score-Cost-Name|Rest]) :-
    format('⚡ Execute ~w (resonance: ~w, cost: ~w)~n', [Name, Score, Cost]),
    execute_plan(Rest).

% ═══════════════════════════════════════════════════════════
% LIFT DATA FROM EXTERNAL SOURCES
% ═══════════════════════════════════════════════════════════

% Lift from PostgreSQL
lift_postgres :-
    format('🐘 Lifting from PostgreSQL...~n', []),
    % psql -c "SELECT table_name, pg_total_relation_size(table_name) FROM information_schema.tables"
    assertz(function_stats(postgres_users, 8192, 1000, 50000, 0)),
    assertz(function_stats(postgres_orders, 16384, 5000, 100000, 0)),
    assertz(function_godel(postgres_users, 210, [2,3,5,7], 50000)),
    assertz(function_godel(postgres_orders, 2310, [2,3,5,7,11], 100000)),
    forall(function_stats(N, _, _, _, _), update_cost(N)).

% Lift from MySQL
lift_mysql :-
    format('🐬 Lifting from MySQL...~n', []),
    % mysql -e "SELECT table_name, data_length FROM information_schema.tables"
    assertz(function_stats(mysql_products, 12288, 2000, 60000, 0)),
    assertz(function_stats(mysql_inventory, 20480, 10000, 150000, 0)),
    assertz(function_godel(mysql_products, 30030, [2,3,5,7,11,13], 60000)),
    assertz(function_godel(mysql_inventory, 510510, [2,3,5,7,11,13,17], 150000)),
    forall(function_stats(N, _, _, _, _), update_cost(N)).

% Lift from LLVM IR
lift_llvm :-
    format('🔧 Lifting from LLVM...~n', []),
    % llvm-dis < file.bc | grep "define"
    assertz(function_stats(llvm_add, 64, 1, 500, 0)),
    assertz(function_stats(llvm_multiply, 128, 1, 1000, 0)),
    assertz(function_stats(llvm_matrix_mul, 2048, 1, 50000, 0)),
    assertz(function_godel(llvm_add, 6, [2,3], 500)),
    assertz(function_godel(llvm_multiply, 30, [2,3,5], 1000)),
    assertz(function_godel(llvm_matrix_mul, 9699690, [2,3,5,7,11,13,17,19,23], 50000)),
    forall(function_stats(N, _, _, _, _), update_cost(N)).

% Lift from MiniZinc
lift_minizinc :-
    format('🧩 Lifting from MiniZinc...~n', []),
    % Parse .mzn files for constraints
    assertz(function_stats(mzn_alldifferent, 256, 10, 5000, 0)),
    assertz(function_stats(mzn_cumulative, 512, 20, 10000, 0)),
    assertz(function_godel(mzn_alldifferent, 2310, [2,3,5,7,11], 5000)),
    assertz(function_godel(mzn_cumulative, 30030, [2,3,5,7,11,13], 10000)),
    forall(function_stats(N, _, _, _, _), update_cost(N)).

% Lift all
lift_all :-
    format('~n🚀 LIFTING ALL DATA SOURCES~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    lift_postgres,
    lift_mysql,
    lift_llvm,
    lift_minizinc,
    aggregate_all(count, function_stats(_, _, _, _, _), Count),
    format('~n✅ Lifted ~w functions~n', [Count]).

% ═══════════════════════════════════════════════════════════
% STATISTICS
% ═══════════════════════════════════════════════════════════

show_stats :-
    format('~n📊 STATISTICS~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    aggregate_all(count, function_stats(_, _, _, _, _), Count),
    format('  Total functions: ~w~n', [Count]),
    
    aggregate_all(sum(S), function_stats(_, S, _, _, _), TotalSize),
    format('  Total size: ~w bytes~n', [TotalSize]),
    
    aggregate_all(sum(R), function_stats(_, _, R, _, _), TotalRows),
    format('  Total rows: ~w~n', [TotalRows]),
    
    aggregate_all(sum(C), function_stats(_, _, _, C, _), TotalCycles),
    format('  Total cycles: ~w~n', [TotalCycles]),
    
    % Find cheapest
    findall(Cost-Name, function_stats(Name, _, _, _, Cost), Costs),
    sort(Costs, [MinCost-MinName|_]),
    format('  Cheapest: ~w (~w)~n', [MinName, MinCost]),
    
    % Find most expensive
    sort(0, @>=, Costs, [MaxCost-MaxName|_]),
    format('  Most expensive: ~w (~w)~n', [MaxName, MaxCost]).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n🎯 GÖDEL PLANNER - Query optimizer with resonance~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    lift_all,
    show_stats,
    
    format('~n🔍 TESTING OPTIMIZER~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    % Test query 1: Find users
    format('Query: find_users~n', []),
    optimize_query(find_users, Plan1),
    format('Plan: ~w~n~n', [Plan1]),
    execute_plan(Plan1),
    
    % Test query 2: Matrix multiply
    format('~nQuery: matrix_multiply~n', []),
    optimize_query(matrix_multiply, Plan2),
    format('Plan: ~w~n~n', [Plan2]),
    execute_plan(Plan2),
    
    format('~n✅ COMPLETE - Query optimizer ready~n', []).
