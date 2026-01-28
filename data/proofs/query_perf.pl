% query_perf.pl - Query perf-enriched data

:- consult('generated/merged_constants.pl').

% ═══════════════════════════════════════════════════════════
% LOAD PERF DATA
% ═══════════════════════════════════════════════════════════

:- dynamic perf_row/6.  % entity, cycles, instructions, cache_misses, time_ns, data

load_perf_csv(File) :-
    format('📊 Loading ~w...~n', [File]),
    setup_call_cleanup(
        open(File, read, S),
        (
            read_line_to_string(S, _Header),
            read_csv_rows(S)
        ),
        close(S)
    ).

read_csv_rows(S) :-
    read_line_to_string(S, Line),
    (   Line == end_of_file -> true
    ;   split_string(Line, ",", "", [E, C, I, M, T | Rest]),
        atom_number(C, Cycles),
        atom_number(I, Instructions),
        atom_number(M, CacheMisses),
        atom_number(T, TimeNs),
        atomic_list_concat(Rest, ',', Data),
        assertz(perf_row(E, Cycles, Instructions, CacheMisses, TimeNs, Data)),
        read_csv_rows(S)
    ).

% ═══════════════════════════════════════════════════════════
% QUERIES
% ═══════════════════════════════════════════════════════════

% Find slowest entities
slowest(N) :-
    findall(T-E, perf_row(E, _, _, _, T, _), Pairs),
    sort(0, @>=, Pairs, Sorted),
    length(Prefix, N),
    append(Prefix, _, Sorted),
    format('🔥 Top ~w slowest:~n', [N]),
    forall(member(Time-Entity, Prefix),
        format('  ~w ns: ~w~n', [Time, Entity])).

% Find most instructions
most_instructions(N) :-
    findall(I-E, perf_row(E, _, I, _, _, _), Pairs),
    sort(0, @>=, Pairs, Sorted),
    length(Prefix, N),
    append(Prefix, _, Sorted),
    format('📈 Top ~w most instructions:~n', [N]),
    forall(member(Inst-Entity, Prefix),
        format('  ~w instructions: ~w~n', [Inst, Entity])).

% Find most cache misses
most_cache_misses(N) :-
    findall(M-E, perf_row(E, _, _, M, _, _), Pairs),
    sort(0, @>=, Pairs, Sorted),
    length(Prefix, N),
    append(Prefix, _, Sorted),
    format('💥 Top ~w most cache misses:~n', [N]),
    forall(member(Misses-Entity, Prefix),
        format('  ~w misses: ~w~n', [Misses, Entity])).

% Assign complexity prime based on perf
assign_complexity_prime(Entity, Prime) :-
    perf_row(Entity, Cycles, _, _, _, _),
    monster_primes(Primes),
    length(Primes, N),
    Index is min(Cycles // 1000, N - 1),
    nth0(Index, Primes, Prime).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n📊 QUERY PERF - Analyze perf-enriched data~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    load_perf_csv('generated/godel_lattice_perf.csv'),
    
    aggregate_all(count, perf_row(_, _, _, _, _, _), Count),
    format('~n  Total rows: ~w~n~n', [Count]),
    
    slowest(5),
    format('~n', []),
    most_instructions(5),
    format('~n', []),
    most_cache_misses(5),
    
    format('~n✅ COMPLETE~n', []).
