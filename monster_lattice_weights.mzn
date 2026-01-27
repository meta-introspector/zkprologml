% Monster Group Lattice Weight Solver
% Maps system complexity to supersingular primes (genus 0)

include "globals.mzn";

% Monster supersingular primes (15 primes)
array[1..15] of int: MONSTER_PRIMES = [2,3,5,7,11,13,17,19,23,29,31,41,47,59,71];

% System components (5 components)
enum Component = {plocate_search, prime_resonance, ngram_lattice, umberto_scholars, deep_q_network};

% Complexity levels: 0 to 71
int: MAX_COMPLEXITY = 71;

% Decision variables: weight of each component
array[Component] of var 0..MAX_COMPLEXITY: weight;

% Decision variables: position in lattice
array[Component] of var 1..15: prime_position;

% Constraint 1: Total complexity = 71 (largest Monster prime)
constraint sum(c in Component)(weight[c]) = MAX_COMPLEXITY;

% Constraint 2: Each component maps to unique prime position
constraint alldifferent([prime_position[c] | c in Component]);

% Constraint 3: Weight must be divisible by corresponding prime
constraint forall(c in Component)(
  weight[c] mod MONSTER_PRIMES[prime_position[c]] = 0
);

% Constraint 4: Heavier components map to larger primes
constraint forall(c1, c2 in Component where c1 < c2)(
  weight[c1] > weight[c2] -> prime_position[c1] > prime_position[c2]
);

% Objective: Maximize lattice density (minimize variance)
var int: variance = sum(c in Component)(
  (weight[c] - MAX_COMPLEXITY div 5) * (weight[c] - MAX_COMPLEXITY div 5)
);

solve minimize variance;

output [
  "🔢 Monster Lattice Weights\n",
  "Total Complexity: \(MAX_COMPLEXITY)\n\n"
] ++
[
  "\(c): weight=\(weight[c]), prime=\(MONSTER_PRIMES[prime_position[c]]) (genus 0)\n"
  | c in Component
] ++
[
  "\nVariance: \(variance)\n",
  "Lattice Density: \(100 - variance div 10)%\n"
];
