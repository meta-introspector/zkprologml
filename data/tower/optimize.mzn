% MiniZinc Model from Datalog
int: n_traces = 1;

% Decision variables
array[1..n_traces] of var 0..1: selected;

% Constraints from Datalog
constraint sum(selected) >= n_traces div 2;

% Objective: maximize activation
var float: total_activation;
constraint total_activation = sum(i in 1..n_traces)(selected[i]);

solve maximize total_activation;

output ["selected = \(selected)\n"];
