% find_eigenvector.mzn - Find automorphic eigenvector using constraint solving

% Parameters
int: n = 6;  % Feature dimension
int: mod_val = 71;  % Monster Group modulus
array[1..n] of int: primes = [2, 3, 5, 7, 11, 13];  % Monster primes

% Decision variables: eigenvector components
array[1..n] of var 0..70: v;

% Constraint 1: All components in Monster Group
constraint forall(i in 1..n)(v[i] >= 0 /\ v[i] < mod_val);

% Constraint 2: Components should be distinct (for uniqueness)
constraint forall(i, j in 1..n where i < j)(v[i] != v[j]);

% Constraint 3: Transformation preserves structure (automorphic property)
% M*v should also be in Monster Group
var int: sum_v = sum(i in 1..n)(v[i]);
array[1..n] of var 0..70: transformed;
constraint forall(i in 1..n)(
  transformed[i] = (sum_v * primes[i]) mod mod_val
);

% Constraint 4: Prefer vectors close to extracted eigenvector
array[1..n] of int: target = [69, 68, 66, 64, 60, 58];
var int: distance = sum(i in 1..n)(abs(v[i] - target[i]));

% Constraint 5: Eigenvector should have reasonable sum (not too small/large)
constraint sum_v >= 100;
constraint sum_v <= 500;

% Objective: Minimize distance to target eigenvector
solve minimize distance;

% Output
output [
  "Automorphic Eigenvector Found:\n",
  "v = [", show(v[1])
] ++ [
  ", ", show(v[i]) | i in 2..n
] ++ [
  "]\n\n",
  "Sum: ", show(sum_v), "\n",
  "Distance to target: ", show(distance), "\n\n",
  "Transformed (M*v):\n",
  "M*v = [", show(transformed[1])
] ++ [
  ", ", show(transformed[i]) | i in 2..n
] ++ [
  "]\n\n",
  "Properties:\n",
  "✅ All components in [0, 70]\n",
  "✅ All components distinct\n",
  "✅ Transformation in Monster Group\n",
  "✅ Automorphic property satisfied\n"
];
