% Example Datalog/Prolog Queries

% Query 1: Find all high-performance layers
% ?- high_performance(Layer).

% Query 2: Find layers with specific prime invariant
% ?- prime_invariant(Layer, 7).

% Query 3: Verify complexity increases
% ?- complexity_increases(0, 1).

% Query 4: Find all Monster prime layers
% ?- monster_layer(Layer, Prime).

% Query 5: Calculate harmonic sum for first 8 layers
% ?- findall(V, (between(0, 7, L), harmonic_value(L, V)), Values),
%    sum_list(Values, Sum).

% Query 6: Find memory-intensive layers
% ?- memory_intensive(Layer).

% Query 7: Get all perf traces
% ?- perf_trace(Layer, Cycles, Instructions, CacheMisses, Branches).

% Query 8: Find layers with IPC > 1.0
% ?- instruction_class(Layer, _, IPC, _), IPC > 1.0.

% Query 9: Group layers by instruction class
% ?- instruction_class(Layer, Class, _, _).

% Query 10: Find harmonic frequencies
% ?- harmonic_layer(Layer, Frequency).
