% Build Schedule Optimizer
% Learned from: prove_monster_nix_store.mzn
% Applied to: 72-level build with Bott periodicity

include "globals.mzn";

% System resources (detected dynamically)
int: NUM_CPUS;
int: MEMORY_GB;

% Bott periodicity (learned pattern)
int: PERIOD = 8;  % Like Monster's power of 2 structure
int: TOTAL_LEVELS = 72;

% Tool costs in seconds (ordered by frequency of use)
array[1..PERIOD] of int: TOOL_COST = [2, 10, 30, 5, 3, 15, 1, 1];
array[1..PERIOD] of string: TOOL_NAME = [
    "rustc", "cargo", "nix", "perf", 
    "strace", "llvm", "objdump", "goblin"
];

% Decision variables
array[1..TOTAL_LEVELS] of var 0..1: execute;
array[1..TOTAL_LEVELS] of var 0..10000: start_time;
array[1..TOTAL_LEVELS] of var 0..10000: end_time;

% Constraint 1: Frequency ordering (learned from Monster)
% Execute most common patterns first
constraint forall(z in 1..TOTAL_LEVELS-1)(
    execute[z] >= execute[z+1]
);

% Constraint 2: Bott periodicity (power of 8 structure)
% Like Monster's 2^46, we have 8^9 = 72 levels
constraint forall(p in 1..PERIOD)(
    sum(z in 1..TOTAL_LEVELS where (z-1) mod PERIOD = p-1)(execute[z]) >= 1
);

% Constraint 3: CPU constraints (resource limits)
constraint forall(t in 0..10000)(
    sum(z in 1..TOTAL_LEVELS where 
        execute[z] = 1 /\ start_time[z] <= t /\ t < end_time[z]
    )(1) <= NUM_CPUS
);

% Constraint 4: Time calculation
constraint forall(z in 1..TOTAL_LEVELS)(
    end_time[z] = start_time[z] + TOOL_COST[(z-1) mod PERIOD + 1] * execute[z]
);

% Objective: Minimize total time (like Monster's maximize coverage)
var int: makespan = max(z in 1..TOTAL_LEVELS)(end_time[z]);

solve minimize makespan;

output [
    "🎯 Optimal Build Schedule\n",
    "CPUs: \(NUM_CPUS), Memory: \(MEMORY_GB)GB\n",
    "Period: \(PERIOD) (Bott), Levels: \(TOTAL_LEVELS)\n\n",
    "Makespan: \(makespan)s = \(makespan div 60)m\n",
    "Levels executed: \(sum(execute))/\(TOTAL_LEVELS)\n\n"
] ++
[
    if execute[z] = 1 then
        "Level \(z-1): \(TOOL_NAME[(z-1) mod PERIOD + 1]) " ++
        "[\(start_time[z])s → \(end_time[z])s]\n"
    else ""
    endif
    | z in 1..TOTAL_LEVELS
];
