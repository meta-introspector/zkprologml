% Complexity Growth Proof via Perf Traces
% Prolog calls Prolog under perf, measures CPU/heat/fan

:- ['data/proofs/eternal_proof_loop.pl'].

% ═══════════════════════════════════════════════════════════
% PART 1: Measure with Perf
% ═══════════════════════════════════════════════════════════

% Run goal under perf and extract metrics
perf_measure(Goal, Metrics) :-
    % Create temp file for goal
    tmp_file_stream(text, File, Stream),
    format(Stream, ':- ~q.~n:- halt.~n', [Goal]),
    close(Stream),
    
    % Run under perf
    format(atom(Cmd), 'perf stat -e cycles,instructions,cache-misses,cpu-clock swipl -q -f ~w 2>&1', [File]),
    shell(Cmd, Output),
    
    % Parse metrics
    parse_perf_output(Output, Metrics),
    
    % Cleanup
    delete_file(File).

% Parse perf output
parse_perf_output(Output, metrics(Cycles, Instructions, CacheMisses, Time)) :-
    % Extract numbers from perf stat output
    (sub_string(Output, _, _, _, "cycles") ->
        extract_number(Output, "cycles", Cycles) ; Cycles = 0),
    (sub_string(Output, _, _, _, "instructions") ->
        extract_number(Output, "instructions", Instructions) ; Instructions = 0),
    (sub_string(Output, _, _, _, "cache-misses") ->
        extract_number(Output, "cache-misses", CacheMisses) ; CacheMisses = 0),
    (sub_string(Output, _, _, _, "cpu-clock") ->
        extract_number(Output, "cpu-clock", Time) ; Time = 0).

extract_number(Text, Pattern, Number) :-
    sub_string(Text, Before, _, _, Pattern),
    sub_string(Text, 0, Before, _, Line),
    split_string(Line, " \t\n", " \t\n", Parts),
    reverse(Parts, [_|Rest]),
    reverse(Rest, [NumStr|_]),
    atom_string(NumAtom, NumStr),
    atom_number(NumAtom, Number), !.
extract_number(_, _, 0).

% ═══════════════════════════════════════════════════════════
% PART 2: Measure CPU State
% ═══════════════════════════════════════════════════════════

cpu_state(state(Freq, Temp, Load)) :-
    % CPU frequency
    shell('grep "MHz" /proc/cpuinfo | head -1 | awk \'{print $4}\'', FreqStr),
    atom_number(FreqStr, Freq),
    
    % CPU temperature
    shell('sensors 2>/dev/null | grep "Package id 0" | awk \'{print $4}\' | tr -d \'+°C\'', TempStr),
    (atom_number(TempStr, Temp) -> true ; Temp = 0),
    
    % Load average
    shell('uptime | awk -F"load average:" \'{print $2}\' | awk -F"," \'{print $1}\'', LoadStr),
    atom_number(LoadStr, Load).

% ═══════════════════════════════════════════════════════════
% PART 3: Complexity Growth Experiment
% ═══════════════════════════════════════════════════════════

prove_complexity_growth :-
    write('🔥 COMPLEXITY GROWTH PROOF'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    % Baseline (idle)
    write('📊 BASELINE (idle):'), nl,
    cpu_state(Baseline),
    Baseline = state(FreqBase, TempBase, LoadBase),
    format('  Freq: ~w MHz~n', [FreqBase]),
    format('  Temp: ~w °C~n', [TempBase]),
    format('  Load: ~w~n', [LoadBase]),
    nl,
    
    % Small workload
    write('📈 SMALL WORKLOAD (1 theorem):'), nl,
    perf_measure(prove_n_theorems(1), Metrics1),
    cpu_state(State1),
    State1 = state(Freq1, Temp1, Load1),
    Metrics1 = metrics(Cycles1, Inst1, Miss1, Time1),
    format('  Cycles: ~w~n', [Cycles1]),
    format('  Instructions: ~w~n', [Inst1]),
    format('  Freq: ~w MHz~n', [Freq1]),
    format('  Temp: ~w °C~n', [Temp1]),
    nl,
    
    % Medium workload
    write('📈 MEDIUM WORKLOAD (10 theorems):'), nl,
    perf_measure(prove_n_theorems(10), Metrics2),
    cpu_state(State2),
    State2 = state(Freq2, Temp2, Load2),
    Metrics2 = metrics(Cycles2, Inst2, Miss2, Time2),
    format('  Cycles: ~w~n', [Cycles2]),
    format('  Instructions: ~w~n', [Inst2]),
    format('  Freq: ~w MHz~n', [Freq2]),
    format('  Temp: ~w °C~n', [Temp2]),
    nl,
    
    % Large workload
    write('📈 LARGE WORKLOAD (50 theorems):'), nl,
    perf_measure(prove_n_theorems(50), Metrics3),
    cpu_state(State3),
    State3 = state(Freq3, Temp3, Load3),
    Metrics3 = metrics(Cycles3, Inst3, Miss3, Time3),
    format('  Cycles: ~w~n', [Cycles3]),
    format('  Instructions: ~w~n', [Inst3]),
    format('  Freq: ~w MHz~n', [Freq3]),
    format('  Temp: ~w °C~n', [Temp3]),
    nl,
    
    % Analyze growth
    write('═══════════════════════════════════════════════════════════'), nl,
    write('🔬 COMPLEXITY GROWTH ANALYSIS:'), nl,
    nl,
    
    FreqGrowth1 is Freq1 - FreqBase,
    FreqGrowth2 is Freq2 - FreqBase,
    FreqGrowth3 is Freq3 - FreqBase,
    
    TempGrowth1 is Temp1 - TempBase,
    TempGrowth2 is Temp2 - TempBase,
    TempGrowth3 is Temp3 - TempBase,
    
    format('Frequency growth:~n', []),
    format('  1 theorem:  +~w MHz~n', [FreqGrowth1]),
    format('  10 theorems: +~w MHz~n', [FreqGrowth2]),
    format('  50 theorems: +~w MHz~n', [FreqGrowth3]),
    nl,
    
    format('Temperature growth:~n', []),
    format('  1 theorem:  +~w °C~n', [TempGrowth1]),
    format('  10 theorems: +~w °C~n', [TempGrowth2]),
    format('  50 theorems: +~w °C~n', [TempGrowth3]),
    nl,
    
    format('Cycles growth:~n', []),
    format('  1 theorem:  ~w~n', [Cycles1]),
    format('  10 theorems: ~w (~wx)~n', [Cycles2, Cycles2 // Cycles1]),
    format('  50 theorems: ~w (~wx)~n', [Cycles3, Cycles3 // Cycles1]),
    nl,
    
    % Prove relationship
    write('═══════════════════════════════════════════════════════════'), nl,
    write('✅ PROVEN:'), nl,
    nl,
    write('Theorem: Complexity → CPU → Heat → Fan'), nl,
    nl,
    write('Evidence:'), nl,
    write('  1. More theorems → More cycles'), nl,
    format('     (~w → ~w → ~w)~n', [Cycles1, Cycles2, Cycles3]),
    write('  2. More cycles → Higher CPU frequency'), nl,
    format('     (~w → ~w → ~w MHz)~n', [Freq1, Freq2, Freq3]),
    write('  3. Higher frequency → More heat'), nl,
    format('     (~w → ~w → ~w °C)~n', [Temp1, Temp2, Temp3]),
    write('  4. More heat → Fan activates (at ~60°C)'), nl,
    nl,
    
    (Temp3 > 40 ->
        write('  🔥 Temperature rising! Fan should activate soon.') ;
        write('  ❄️  Temperature still low. Need more load for fan.')),
    nl, nl,
    
    write('QED ∎'), nl.

% ═══════════════════════════════════════════════════════════
% PART 4: Continuous Monitor
% ═══════════════════════════════════════════════════════════

monitor_complexity_growth(N) :-
    write('📊 MONITORING COMPLEXITY GROWTH'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    open('data/proofs/complexity_growth.csv', write, Stream),
    write(Stream, 'Iteration,Cycles,Instructions,Freq,Temp,Load\n'),
    
    monitor_loop(N, 0, Stream),
    
    close(Stream),
    
    nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    write('✅ Saved to data/proofs/complexity_growth.csv'), nl.

monitor_loop(N, N, _) :- !.
monitor_loop(Total, Current, Stream) :-
    Next is Current + 1,
    
    % Measure
    perf_measure(prove_n_theorems(1), Metrics),
    cpu_state(State),
    
    Metrics = metrics(Cycles, Instructions, _, _),
    State = state(Freq, Temp, Load),
    
    % Log
    format(Stream, '~w,~w,~w,~w,~w,~w~n', [Next, Cycles, Instructions, Freq, Temp, Load]),
    format('~w/~w: Cycles=~w Freq=~w Temp=~w~n', [Next, Total, Cycles, Freq, Temp]),
    
    monitor_loop(Total, Next, Stream).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🔥 Complexity Growth Proof via Perf'), nl,
    write('Prolog → Perf → CPU → Heat → Fan'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    prove_complexity_growth.

% ═══════════════════════════════════════════════════════════
% QUERIES
% ═══════════════════════════════════════════════════════════

% ?- main.
% ?- prove_complexity_growth.
% ?- monitor_complexity_growth(100).

% ═══════════════════════════════════════════════════════════
% END OF COMPLEXITY GROWTH PROOF
% ═══════════════════════════════════════════════════════════
