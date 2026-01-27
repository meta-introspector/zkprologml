% MiniZinc Model: Intelligent Search Expansion
% Given: seed terms, lattice structure, performance constraints
% Goal: Maximize information gain while minimizing cost

% Parameters
int: num_terms = 8;
set of int: TERMS = 1..num_terms;
array[TERMS] of string: term_names = ["github", "search", "index", "crawler", "scraper", "octocrab", "fuzzy", "fulltext"];
array[TERMS] of int: current_files = [3747, 3500, 1800, 360, 360, 1800, 1080, 360];
array[TERMS] of int: lattice_points = [43200, 22278, 1800, 360, 360, 1800, 1080, 360];
array[TERMS] of float: avg_resonance = [8.53, 131.17, 14.44, 10.42, 15.82, 8.38, 30.15, 112.82];

% Decision variables
array[TERMS] of var 0..1: expand;  % Which terms to expand
array[TERMS] of var 0..100: depth;  % How deep to search

% Constraints
constraint sum(expand) >= 1;  % Expand at least one term
constraint sum(expand) <= 4;  % Don't expand more than 4 (resource limit)

% Prioritize high resonance, low current coverage
array[TERMS] of var float: information_gain = 
  [avg_resonance[i] * (1.0 - (int2float(current_files[i]) / 10000.0)) | i in TERMS];

% Cost model: files * depth * complexity
array[TERMS] of var float: cost = 
  [int2float(current_files[i] * depth[i]) / 1000.0 | i in TERMS];

% Objective: maximize information gain / cost ratio
var float: total_gain = sum(i in TERMS)(expand[i] * information_gain[i] * int2float(depth[i]));
var float: total_cost = sum(i in TERMS)(expand[i] * cost[i]) + 0.001;
var float: efficiency = total_gain / total_cost;

solve maximize efficiency;

output [
  "Optimal Search Expansion:\n",
  "========================\n"
] ++
[
  if expand[i] == 1 then
    term_names[i] ++ ": depth=" ++ show(depth[i]) ++ 
    " gain=" ++ show_float(3, 2, information_gain[i]) ++
    " cost=" ++ show_float(3, 2, cost[i]) ++ "\n"
  else "" endif
  | i in TERMS
] ++
[
  "\nTotal Efficiency: " ++ show_float(5, 2, efficiency) ++ "\n",
  "Total Gain: " ++ show_float(5, 2, total_gain) ++ "\n",
  "Total Cost: " ++ show_float(5, 2, total_cost) ++ "\n"
];
