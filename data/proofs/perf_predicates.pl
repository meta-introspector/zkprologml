% perf_predicates.pl - Associate perf data with every fact/function/row

:- consult('generated/merged_constants.pl').

% ═══════════════════════════════════════════════════════════
% PERF DATA SCHEMA
% ═══════════════════════════════════════════════════════════

:- dynamic perf_data/5.  % entity, cycles, instructions, cache_misses, time_ns

% ═══════════════════════════════════════════════════════════
% MEASURE PERF FOR ANY GOAL
% ═══════════════════════════════════════════════════════════

measure_perf(Goal, Cycles, Instructions, CacheMisses, TimeNs) :-
    % Get perf stat for goal execution
    get_time(T0),
    statistics(cputime, CPU0),
    call(Goal),
    statistics(cputime, CPU1),
    get_time(T1),
    
    % Calculate metrics
    TimeNs is round((T1 - T0) * 1_000_000_000),
    CPUTime is CPU1 - CPU0,
    
    % Estimate cycles and instructions (real perf would use perf_event_open)
    Cycles is round(CPUTime * 2_400_000_000),  % 2.4 GHz CPU
    Instructions is round(Cycles * 1.5),        % ~1.5 IPC
    CacheMisses is round(Instructions / 1000).  % ~0.1% miss rate

% ═══════════════════════════════════════════════════════════
% ATTACH PERF TO PREDICATE
% ═══════════════════════════════════════════════════════════

attach_perf(Predicate) :-
    functor(Predicate, Name, Arity),
    format(atom(Entity), '~w/~w', [Name, Arity]),
    
    % Measure performance
    measure_perf(Predicate, Cycles, Instructions, CacheMisses, TimeNs),
    
    % Store perf data
    assertz(perf_data(Entity, Cycles, Instructions, CacheMisses, TimeNs)),
    
    format('⚡ ~w: ~w cycles, ~w instructions, ~w ns~n', 
           [Entity, Cycles, Instructions, TimeNs]).

% ═══════════════════════════════════════════════════════════
% PROFILE ALL PREDICATES
% ═══════════════════════════════════════════════════════════

profile_all :-
    format('⚡ Profiling all predicates...~n~n', []),
    
    % Profile Monster primes
    forall(monster_prime(P), 
        attach_perf(monster_prime(P))),
    
    % Profile emoji mappings
    forall(emoji_prime(P, E),
        attach_perf(emoji_prime(P, E))),
    
    % Profile type mappings
    forall(type_prime(T, P),
        attach_perf(type_prime(T, P))),
    
    format('~n✅ Profiling complete~n', []).

% ═══════════════════════════════════════════════════════════
% EXPORT PERF DATA
% ═══════════════════════════════════════════════════════════

export_perf_csv :-
    open('generated/perf_data.csv', write, S),
    write(S, 'entity,cycles,instructions,cache_misses,time_ns\n'),
    forall(perf_data(E, C, I, M, T),
        format(S, '~w,~w,~w,~w,~w~n', [E, C, I, M, T])),
    close(S),
    
    aggregate_all(count, perf_data(_, _, _, _, _), Count),
    format('📊 Exported ~w perf measurements to generated/perf_data.csv~n', [Count]).

% ═══════════════════════════════════════════════════════════
% QUERY PERF DATA
% ═══════════════════════════════════════════════════════════

% Get perf for entity
entity_perf(Entity, Cycles, Instructions, CacheMisses, TimeNs) :-
    perf_data(Entity, Cycles, Instructions, CacheMisses, TimeNs).

% Find slowest predicates
slowest(N, Results) :-
    findall(T-E, perf_data(E, _, _, _, T), Pairs),
    sort(0, @>=, Pairs, Sorted),
    length(Prefix, N),
    append(Prefix, _, Sorted),
    Results = Prefix.

% Find most cache misses
most_cache_misses(N, Results) :-
    findall(M-E, perf_data(E, _, _, M, _), Pairs),
    sort(0, @>=, Pairs, Sorted),
    length(Prefix, N),
    append(Prefix, _, Sorted),
    Results = Prefix.

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n⚡ PERF PREDICATES - Associate perf with every fact~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    profile_all,
    export_perf_csv,
    
    format('~n📊 STATISTICS~n', []),
    aggregate_all(count, perf_data(_, _, _, _, _), Count),
    format('  Total measurements: ~w~n', [Count]),
    
    aggregate_all(sum(C), perf_data(_, C, _, _, _), TotalCycles),
    format('  Total cycles: ~w~n', [TotalCycles]),
    
    aggregate_all(sum(I), perf_data(_, _, I, _, _), TotalInstructions),
    format('  Total instructions: ~w~n', [TotalInstructions]),
    
    format('~n🔥 Top 5 slowest:~n', []),
    slowest(5, Slow),
    forall(member(T-E, Slow),
        format('  ~w: ~w ns~n', [E, T])),
    
    format('~n✅ COMPLETE~n', []).
