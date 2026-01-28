% continuous_improve.pl - Continuous improvement using live perf data

:- consult('generated/merged_constants.pl').

% ═══════════════════════════════════════════════════════════
% COLLECT PERF DATA
% ═══════════════════════════════════════════════════════════

collect_perf_data :-
    format('📊 Collecting perf data...~n', []),
    shell('cd /mnt/data1/nix/vendor/rust/github/data/proofs && ./perf_collector', _),
    format('✅ Perf data collected~n', []).

% ═══════════════════════════════════════════════════════════
% LOAD LATEST PERF DATA
% ═══════════════════════════════════════════════════════════

:- dynamic perf_sample/6.  % timestamp, entity, cycles, instructions, cache_misses, time_ns

load_latest_perf :-
    format('📥 Loading latest perf data...~n', []),
    retractall(perf_sample(_, _, _, _, _, _)),
    
    setup_call_cleanup(
        open('generated/perf_samples.csv', read, S),
        (
            read_line_to_string(S, _Header),
            read_perf_lines(S)
        ),
        close(S)
    ),
    
    aggregate_all(count, perf_sample(_, _, _, _, _, _), Count),
    format('  Loaded ~w samples~n', [Count]).

read_perf_lines(S) :-
    read_line_to_string(S, Line),
    (   Line == end_of_file -> true
    ;   split_string(Line, ",", "", [TS, E, C, I, M, T]),
        atom_number(TS, Timestamp),
        atom_number(C, Cycles),
        atom_number(I, Instructions),
        atom_number(M, CacheMisses),
        atom_number(T, TimeNs),
        assertz(perf_sample(Timestamp, E, Cycles, Instructions, CacheMisses, TimeNs)),
        read_perf_lines(S)
    ).

% ═══════════════════════════════════════════════════════════
% ANALYZE & PLAN
% ═══════════════════════════════════════════════════════════

analyze_and_plan :-
    format('~n🔍 Analyzing perf data...~n', []),
    
    % Find slowest operations
    findall(T-E, perf_sample(_, E, _, _, _, T), Times),
    sort(0, @>=, Times, Sorted),
    
    format('~n⚠️  Slowest operations:~n', []),
    forall(member(Time-Entity, Sorted),
        format('  ~w: ~w ns (~2f ms)~n', [Entity, Time, Time/1000000])),
    
    % Calculate total cost
    aggregate_all(sum(T), perf_sample(_, _, _, _, _, T), TotalTime),
    format('~n📊 Total time: ~w ns (~2f ms)~n', [TotalTime, TotalTime/1000000]),
    
    % Suggest improvements
    format('~n💡 Improvement suggestions:~n', []),
    forall(member(T-E, Sorted), (
        T > 1000000,
        format('  ⚡ Optimize ~w (save ~2f ms)~n', [E, T/1000000])
    )).

% ═══════════════════════════════════════════════════════════
% CONTINUOUS LOOP
% ═══════════════════════════════════════════════════════════

continuous_improve(0) :-
    format('~n✅ Continuous improvement complete~n', []).

continuous_improve(N) :-
    N > 0,
    format('~n🔄 CYCLE ~w~n', [N]),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    % Collect fresh perf data
    collect_perf_data,
    
    % Load it
    load_latest_perf,
    
    % Analyze and plan
    analyze_and_plan,
    
    % Wait before next cycle
    format('~n⏱️  Waiting 10 seconds...~n', []),
    sleep(10),
    
    N1 is N - 1,
    continuous_improve(N1).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n🔄 CONTINUOUS IMPROVEMENT - Using live perf data~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    % Run 3 cycles
    continuous_improve(3),
    
    format('~n📊 FINAL REPORT~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    aggregate_all(count, perf_sample(_, _, _, _, _, _), Samples),
    aggregate_all(sum(C), perf_sample(_, _, C, _, _, _), TotalCycles),
    aggregate_all(sum(T), perf_sample(_, _, _, _, _, T), TotalTime),
    
    format('  Total samples: ~w~n', [Samples]),
    format('  Total cycles: ~w~n', [TotalCycles]),
    format('  Total time: ~w ns (~2f ms)~n', [TotalTime, TotalTime/1000000]),
    
    format('~n✅ SYSTEM IS SELF-MONITORING~n', []).
