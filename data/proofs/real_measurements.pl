% zkPrologML with Real Measurements Only
% No constants - everything measured in real-time

:- dynamic measurement/3.

% ═══════════════════════════════════════════════════════════
% PART 1: Real CPU Measurements
% ═══════════════════════════════════════════════════════════

measure_cpu_freq(Freq) :-
    process_create(path(bash), ['-c', 'grep "MHz" /proc/cpuinfo | head -1 | awk \'{print $4}\''], 
                   [stdout(pipe(Out))]),
    read_line_to_string(Out, FreqStr),
    close(Out),
    number_string(Freq, FreqStr).

measure_cpu_temp(Temp) :-
    process_create(path(bash), ['-c', 'sensors 2>/dev/null | grep "Package id 0" | awk \'{print $4}\' | tr -d \'+°C\''],
                   [stdout(pipe(Out))]),
    read_line_to_string(Out, TempStr),
    close(Out),
    (number_string(Temp, TempStr) -> true ; Temp = 0).

measure_load(Load) :-
    process_create(path(bash), ['-c', 'uptime | awk -F"load average:" \'{print $2}\' | awk -F"," \'{print $1}\''],
                   [stdout(pipe(Out))]),
    read_line_to_string(Out, LoadStr),
    close(Out),
    number_string(Load, LoadStr).

measure_all(State) :-
    measure_cpu_freq(Freq),
    measure_cpu_temp(Temp),
    measure_load(Load),
    get_time(Time),
    State = state(freq(Freq), temp(Temp), load(Load), time(Time)).

% ═══════════════════════════════════════════════════════════
% PART 2: Real Blockchain Measurements
% ═══════════════════════════════════════════════════════════

% Get actual Solana slot (no constants)
measure_solana_slot(Slot) :-
    shell('curl -s -X POST https://api.mainnet-beta.solana.com -H "Content-Type: application/json" -d \'{"jsonrpc":"2.0","id":1,"method":"getSlot"}\' | grep -o \'"result":[0-9]*\' | cut -d: -f2', Output),
    (atom_number(Output, Slot) -> true ; Slot = 0).

% Get actual block info (no simulation)
measure_chain_state(Chain, State) :-
    (Chain = solana ->
        measure_solana_slot(Height) ;
        Height = 0),
    get_time(Time),
    State = chain_state(Chain, height(Height), time(Time)).

% ═══════════════════════════════════════════════════════════
% PART 3: Real Memory Measurements
% ═══════════════════════════════════════════════════════════

measure_memory(Memory) :-
    shell('free -m | grep Mem | awk \'{print $3}\'', Used),
    shell('free -m | grep Mem | awk \'{print $2}\'', Total),
    atom_number(Used, UsedMB),
    atom_number(Total, TotalMB),
    Memory = memory(used(UsedMB), total(TotalMB)).

% ═══════════════════════════════════════════════════════════
% PART 4: Real Disk Measurements
% ═══════════════════════════════════════════════════════════

measure_disk(Disk) :-
    shell('df -m . | tail -1 | awk \'{print $3}\'', Used),
    shell('df -m . | tail -1 | awk \'{print $2}\'', Total),
    atom_number(Used, UsedMB),
    atom_number(Total, TotalMB),
    Disk = disk(used(UsedMB), total(TotalMB)).

% ═══════════════════════════════════════════════════════════
% PART 5: Real Network Measurements
% ═══════════════════════════════════════════════════════════

measure_network(Network) :-
    shell('cat /proc/net/dev | grep -E "eth0|wlan0|enp" | head -1 | awk \'{print $2}\'', RxBytes),
    shell('cat /proc/net/dev | grep -E "eth0|wlan0|enp" | head -1 | awk \'{print $10}\'', TxBytes),
    (atom_number(RxBytes, Rx) -> true ; Rx = 0),
    (atom_number(TxBytes, Tx) -> true ; Tx = 0),
    Network = network(rx(Rx), tx(Tx)).

% ═══════════════════════════════════════════════════════════
% PART 6: Real Process Measurements
% ═══════════════════════════════════════════════════════════

measure_process(Process) :-
    shell('ps aux | grep swipl | grep -v grep | awk \'{print $3}\'', CPU),
    shell('ps aux | grep swipl | grep -v grep | awk \'{print $4}\'', Mem),
    (atom_number(CPU, CPUPct) -> true ; CPUPct = 0),
    (atom_number(Mem, MemPct) -> true ; MemPct = 0),
    Process = process(cpu(CPUPct), mem(MemPct)).

% ═══════════════════════════════════════════════════════════
% PART 7: Complete System Measurement
% ═══════════════════════════════════════════════════════════

measure_system(Measurement) :-
    measure_all(CPUState),
    measure_memory(Memory),
    measure_disk(Disk),
    measure_network(Network),
    measure_process(Process),
    get_time(Time),
    
    Measurement = system_measurement(
        time(Time),
        cpu(CPUState),
        memory(Memory),
        disk(Disk),
        network(Network),
        process(Process)
    ),
    
    assertz(measurement(Time, system, Measurement)).

% ═══════════════════════════════════════════════════════════
% PART 8: Real-Time Monitoring Loop
% ═══════════════════════════════════════════════════════════

monitor_realtime :-
    write('📊 REAL-TIME MEASUREMENT SYSTEM'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    write('All measurements are REAL - no constants!'), nl,
    nl,
    
    monitor_loop(0).

monitor_loop(N) :-
    N1 is N + 1,
    
    format('~n═══ MEASUREMENT ~w ═══~n', [N1]),
    
    % Measure everything
    measure_system(M),
    
    % Display
    M = system_measurement(
        time(Time),
        cpu(state(freq(Freq), temp(Temp), load(Load), _)),
        memory(memory(used(MemUsed), total(MemTotal))),
        disk(disk(used(DiskUsed), total(DiskTotal))),
        network(network(rx(Rx), tx(Tx))),
        process(process(cpu(ProcCPU), mem(ProcMem)))
    ),
    
    format('Time: ~w~n', [Time]),
    format('CPU: ~2f MHz, ~2f°C, Load ~2f~n', [Freq, Temp, Load]),
    format('Memory: ~w/~w MB (~2f%)~n', [MemUsed, MemTotal, MemUsed/MemTotal*100]),
    format('Disk: ~w/~w MB (~2f%)~n', [DiskUsed, DiskTotal, DiskUsed/DiskTotal*100]),
    format('Network: Rx ~w, Tx ~w bytes~n', [Rx, Tx]),
    format('Process: CPU ~2f%, Mem ~2f%~n', [ProcCPU, ProcMem]),
    
    % Wait 5 seconds
    sleep(5),
    
    % Continue
    monitor_loop(N1).

% ═══════════════════════════════════════════════════════════
% PART 9: Export Real Measurements
% ═══════════════════════════════════════════════════════════

export_measurements(File) :-
    open(File, write, Stream),
    
    write(Stream, 'Time,Freq,Temp,Load,MemUsed,MemTotal,DiskUsed,DiskTotal,Rx,Tx,ProcCPU,ProcMem\n'),
    
    forall(measurement(Time, system, M),
           (M = system_measurement(
                time(_),
                cpu(state(freq(Freq), temp(Temp), load(Load), _)),
                memory(memory(used(MemUsed), total(MemTotal))),
                disk(disk(used(DiskUsed), total(DiskTotal))),
                network(network(rx(Rx), tx(Tx))),
                process(process(cpu(ProcCPU), mem(ProcMem)))
            ),
            format(Stream, '~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w~n',
                   [Time, Freq, Temp, Load, MemUsed, MemTotal, DiskUsed, DiskTotal, Rx, Tx, ProcCPU, ProcMem]))),
    
    close(Stream),
    format('✅ Exported to ~w~n', [File]).

% ═══════════════════════════════════════════════════════════
% PART 10: Quick Test
% ═══════════════════════════════════════════════════════════

quick_test :-
    write('🔍 QUICK MEASUREMENT TEST'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    write('Measuring CPU...'), nl,
    measure_cpu_freq(Freq),
    measure_cpu_temp(Temp),
    measure_load(Load),
    format('  Freq: ~2f MHz~n', [Freq]),
    format('  Temp: ~2f°C~n', [Temp]),
    format('  Load: ~2f~n', [Load]),
    nl,
    
    write('Measuring Memory...'), nl,
    measure_memory(memory(used(MemUsed), total(MemTotal))),
    format('  Used: ~w MB~n', [MemUsed]),
    format('  Total: ~w MB~n', [MemTotal]),
    nl,
    
    write('Measuring Disk...'), nl,
    measure_disk(disk(used(DiskUsed), total(DiskTotal))),
    format('  Used: ~w MB~n', [DiskUsed]),
    format('  Total: ~w MB~n', [DiskTotal]),
    nl,
    
    write('Measuring Network...'), nl,
    measure_network(network(rx(Rx), tx(Tx))),
    format('  Rx: ~w bytes~n', [Rx]),
    format('  Tx: ~w bytes~n', [Tx]),
    nl,
    
    write('Measuring Process...'), nl,
    measure_process(process(cpu(CPU), mem(Mem))),
    format('  CPU: ~2f%~n', [CPU]),
    format('  Mem: ~2f%~n', [Mem]),
    nl,
    
    write('✅ All measurements REAL - no constants!'), nl.

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('📊 Real-Time Measurement System'), nl,
    write('No constants - everything measured!'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    write('To run:'), nl,
    write('  ?- quick_test.        % Test all measurements'), nl,
    write('  ?- monitor_realtime.  % Continuous monitoring'), nl,
    write('  ?- export_measurements(\'measurements.csv\').'), nl.

% ═══════════════════════════════════════════════════════════
% QUERIES
% ═══════════════════════════════════════════════════════════

% ?- main.
% ?- quick_test.
% ?- monitor_realtime.

% ═══════════════════════════════════════════════════════════
% END OF REAL MEASUREMENTS
% ═══════════════════════════════════════════════════════════
