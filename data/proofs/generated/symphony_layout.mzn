% Optimize Prolog Symphony Layout
% Find best ordering to minimize dissonance

int: n = 24;  % number of files
array[1..n] of int: complexity = [1887, 3, 273, 798, 1482, 6, 357, 105, 39, 101010, 102, 399, 3, 14763, 798, 6, 357, 105, 21, 3, 6, 165, 21, 51];

array[1..n] of var 1..n: order;  % permutation

constraint alldifferent(order);

% Dissonance = sum of complexity jumps
var int: total_dissonance = sum(i in 1..n-1)(
  abs(complexity[order[i+1]] - complexity[order[i]])
);

solve minimize total_dissonance;

output [
  "Optimal order: " ++ show(order) ++ "\n",
  "Total dissonance: " ++ show(total_dissonance) ++ "\n"
];
