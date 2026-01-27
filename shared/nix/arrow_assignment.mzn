% Arrow Assignment: LLM Weights → Prolog Traces
% Using MiniZinc to find optimal mapping

include "globals.mzn";

% ═══════════════════════════════════════════════════════════
% PARAMETERS
% ═══════════════════════════════════════════════════════════

% Number of weight samples
int: n_weights;

% Number of Prolog trace points
int: n_traces;

% LLM weights (normalized to [0,1])
array[1..n_weights] of float: weights;

% Prolog trace complexities (instruction counts)
array[1..n_traces] of int: complexities;

% ═══════════════════════════════════════════════════════════
% DECISION VARIABLES
% ═══════════════════════════════════════════════════════════

% Arrow: which weight maps to which trace
array[1..n_weights] of var 1..n_traces: arrow;

% ═══════════════════════════════════════════════════════════
% CONSTRAINTS
% ═══════════════════════════════════════════════════════════

% Each trace should be covered by at least one weight
constraint forall(t in 1..n_traces)(
  exists(w in 1..n_weights)(arrow[w] = t)
);

% Monotonicity: higher weights → higher complexity
constraint forall(w1, w2 in 1..n_weights where w1 < w2)(
  weights[w1] <= weights[w2] -> 
  complexities[arrow[w1]] <= complexities[arrow[w2]]
);

% ═══════════════════════════════════════════════════════════
% OBJECTIVE
% ═══════════════════════════════════════════════════════════

% Minimize mismatch between normalized weights and complexities
var float: mismatch = sum(w in 1..n_weights)(
  abs(weights[w] - complexities[arrow[w]] / max(complexities))
);

solve minimize mismatch;

% ═══════════════════════════════════════════════════════════
% OUTPUT
% ═══════════════════════════════════════════════════════════

output [
  "% Arrow Assignment Results\n",
  "% Mismatch: ", show(mismatch), "\n\n",
  "arrows = [\n"
] ++
[
  "  weight[", show(w), "] = ", show_float(3, 2, weights[w]), 
  " -> trace[", show(arrow[w]), "] = ", show(complexities[arrow[w]]), "\n"
  | w in 1..n_weights
] ++
[
  "];\n"
];
