% Optimal Build Plan Solver
% Uses Bott periodicity and available resources

include "globals.mzn";

% System resources (to be detected)
int: NUM_CPUS;  % Will be passed as parameter
int: MEMORY_GB; % Will be passed as parameter

% Bott periodicity
int: PERIOD = 8;
int: TOTAL_LEVELS = 72;
int: OCTAVES = TOTAL_LEVELS div PERIOD;

% Tool costs (seconds)
array[1..PERIOD] of int: TOOL_COST = [2, 10, 30, 5, 3, 15, 1, 1];

% Decision variables
array[1..TOTAL_LEVELS] of var 0..1: execute;  % Execute this level?
array[1..TOTAL_LEVELS] of var 0..NUM_CPUS: cpu_assigned;  % Which CPU?
array[1..TOTAL_LEVELS] of var 0..1000: start_time;  % When to start?

% Constraint 1: Execute at least one of each pattern
constraint forall(p in 1..PERIOD)(
  sum(z in 1..TOTAL_LEVELS where (z-1) mod PERIOD = p-1)(execute[z]) >= 1
);

% Constraint 2: No CPU overload
constraint forall(t in 0..1000)(
  sum(z in 1..TOTAL_LEVELS where 
      execute[z] = 1 /\ 
      start_time[z] <= t /\ 
      t < start_time[z] + TOOL_COST[(z-1) mod PERIOD + 1]
  )(1) <= NUM_CPUS
);

% Constraint 3: Bott periodicity - can skip redundant octaves
constraint forall(p in 1..PERIOD, oct in 2..OCTAVES)(
  let { 
    var int: z1 = p + (oct-1) * PERIOD;
    var int: z0 = p;
  } in
  execute[z1] <= execute[z0]  % Only execute if base pattern executed
);

% Objective: Minimize total time
var int: total_time = max(z in 1..TOTAL_LEVELS where execute[z] = 1)(
  start_time[z] + TOOL_COST[(z-1) mod PERIOD + 1]
);

solve minimize total_time;

output [
  "🎯 Optimal Build Plan\n",
  "CPUs: \(NUM_CPUS), Memory: \(MEMORY_GB)GB\n\n",
  "Levels to execute: \(sum(execute))/\(TOTAL_LEVELS)\n",
  "Total time: \(total_time)s = \(total_time div 60)m\n\n",
  "Schedule:\n"
] ++
[
  if execute[z] = 1 then
    "  Level \(z-1): CPU \(cpu_assigned[z]), start \(start_time[z])s\n"
  else ""
  endif
  | z in 1..TOTAL_LEVELS
];
