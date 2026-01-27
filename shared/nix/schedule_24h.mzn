% 24-Hour Schedule Optimization with Temperature Constraints
% MiniZinc model for optimal execution plan

include "globals.mzn";

% ═══════════════════════════════════════════════════════════
% PARAMETERS
% ═══════════════════════════════════════════════════════════

% Time parameters
int: hours = 24;                    % Total execution time
int: reports = 24;                  % Number of reports (1 per hour)

% Complexity parameters
int: total_levels = 72;             % Total complexity levels (Z₀₋₇₁)
int: min_levels_per_hour = 1;       % Minimum levels per hour
int: max_levels_per_hour = 10;      % Maximum levels per hour

% Temperature parameters
array[1..total_levels] of float: level_temp_gain;  % Expected temp gain per level
float: max_temp_per_hour = 5.0;     % Maximum temperature gain per hour
float: max_total_temp = 50.0;       % Maximum total temperature gain

% Instruction counts per level
array[1..total_levels] of int: level_instructions;

% ═══════════════════════════════════════════════════════════
% DECISION VARIABLES
% ═══════════════════════════════════════════════════════════

% How many levels to execute in each hour
array[1..hours] of var min_levels_per_hour..max_levels_per_hour: levels_per_hour;

% Which levels are executed in which hour
array[1..total_levels] of var 1..hours: level_to_hour;

% Temperature gain per hour
array[1..hours] of var 0.0..max_temp_per_hour: temp_per_hour;

% Cumulative temperature
array[1..hours] of var 0.0..max_total_temp: cumulative_temp;

% ═══════════════════════════════════════════════════════════
% CONSTRAINTS
% ═══════════════════════════════════════════════════════════

% 1. All levels must be executed exactly once
constraint sum(levels_per_hour) = total_levels;

% 2. Levels are assigned sequentially to hours
constraint forall(h in 1..hours)(
  count(level_to_hour, h) = levels_per_hour[h]
);

% 3. Temperature per hour is sum of level temps
constraint forall(h in 1..hours)(
  temp_per_hour[h] = sum(l in 1..total_levels where level_to_hour[l] = h)(
    level_temp_gain[l]
  )
);

% 4. Temperature per hour doesn't exceed maximum
constraint forall(h in 1..hours)(
  temp_per_hour[h] <= max_temp_per_hour
);

% 5. Cumulative temperature
constraint cumulative_temp[1] = temp_per_hour[1];
constraint forall(h in 2..hours)(
  cumulative_temp[h] = cumulative_temp[h-1] + temp_per_hour[h]
);

% 6. Total temperature doesn't exceed maximum
constraint cumulative_temp[hours] <= max_total_temp;

% 7. Monotonicity: higher complexity levels later
constraint forall(l1, l2 in 1..total_levels where l1 < l2)(
  level_to_hour[l1] <= level_to_hour[l2]
);

% ═══════════════════════════════════════════════════════════
% OBJECTIVES
% ═══════════════════════════════════════════════════════════

% Minimize temperature variance (even distribution)
var float: temp_variance = variance(temp_per_hour);

% Minimize maximum temperature spike
var float: max_temp_spike = max(temp_per_hour);

% Multi-objective: minimize both
var float: objective = temp_variance + max_temp_spike;

solve minimize objective;

% ═══════════════════════════════════════════════════════════
% OUTPUT
% ═══════════════════════════════════════════════════════════

output [
  "% 24-Hour Execution Schedule\n",
  "% Optimized for even temperature distribution\n\n",
  "schedule = [\n"
] ++
[
  "  hour_", show(h), ": levels=", show(levels_per_hour[h]), 
  ", temp=", show_float(3, 2, temp_per_hour[h]), 
  ", cumulative=", show_float(3, 2, cumulative_temp[h]), "\n"
  | h in 1..hours
] ++
[
  "];\n\n",
  "total_temp_gain = ", show_float(3, 2, cumulative_temp[hours]), "\n",
  "temp_variance = ", show_float(3, 2, temp_variance), "\n",
  "max_temp_spike = ", show_float(3, 2, max_temp_spike), "\n"
];
