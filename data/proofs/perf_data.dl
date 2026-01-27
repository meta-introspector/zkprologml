% Perf Data Facts (Auto-generated)

% Schema:
% perf_trace(Layer, Cycles, Instructions, CacheMisses, Branches).
% instruction_class(Layer, Class, IPC, MissRate).
% prime_invariant(Layer, Prime).
% harmonic_layer(Layer, Frequency).

perf_trace(0, 800, 1000, 10, 150).
instruction_class(0, mixed, 1.25, 0.0100).
prime_invariant(0, 2).
harmonic_layer(0, 2).
perf_trace(1, 1608, 2010, 20, 301).
instruction_class(1, mixed, 1.25, 0.0100).
prime_invariant(1, 3).
harmonic_layer(1, 3).
perf_trace(2, 2432, 3040, 30, 456).
instruction_class(2, mixed, 1.25, 0.0099).
prime_invariant(2, 5).
harmonic_layer(2, 5).
perf_trace(3, 3272, 4090, 40, 613).
instruction_class(3, mixed, 1.25, 0.0098).
prime_invariant(3, 7).
harmonic_layer(3, 7).
perf_trace(4, 4128, 5160, 51, 774).
instruction_class(4, mixed, 1.25, 0.0099).
prime_invariant(4, 11).
harmonic_layer(4, 11).
perf_trace(5, 5000, 6250, 62, 937).
instruction_class(5, mixed, 1.25, 0.0099).
prime_invariant(5, 13).
harmonic_layer(5, 13).
perf_trace(6, 5888, 7360, 73, 1104).
instruction_class(6, mixed, 1.25, 0.0099).
prime_invariant(6, 17).
harmonic_layer(6, 17).
perf_trace(7, 6792, 8490, 84, 1273).
instruction_class(7, mixed, 1.25, 0.0099).
prime_invariant(7, 19).
harmonic_layer(7, 19).

% Derived Rules:

% Complexity increases monotonically
complexity_increases(L1, L2) :-
    perf_trace(L1, _, I1, _, _),
    perf_trace(L2, _, I2, _, _),
    L1 < L2,
    I1 < I2.

% High performance instructions
high_performance(Layer) :-
    instruction_class(Layer, _, IPC, _),
    IPC > 2.0.

% Memory intensive instructions
memory_intensive(Layer) :-
    instruction_class(Layer, _, _, MissRate),
    MissRate > 0.1.

% Monster prime layers
monster_layer(Layer, Prime) :-
    prime_invariant(Layer, Prime),
    monster_prime(Prime).

% Monster primes
monster_prime(2).
monster_prime(3).
monster_prime(5).
monster_prime(7).
monster_prime(11).
monster_prime(13).
monster_prime(17).
monster_prime(19).
monster_prime(23).
monster_prime(29).
monster_prime(31).
monster_prime(41).
monster_prime(47).
monster_prime(59).
monster_prime(71).

% Harmonic series
harmonic_value(Layer, Value) :-
    harmonic_layer(Layer, Freq),
    Value is 1 / Freq.

