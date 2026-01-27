% Meta-MiniZinc: Reasons about MiniZinc models
% Self-referential constraint solver

include "globals.mzn";

% Known MiniZinc models in our system
int: NUM_MODELS = 3;  % Monster, Build Schedule, and this one!

% Model properties (extracted from catalog)
array[1..NUM_MODELS] of string: MODEL_NAME = [
    "prove_monster_nix_store",
    "build_schedule", 
    "meta_minizinc"
];

array[1..NUM_MODELS] of int: NUM_LAYERS = [46, 72, 3];  % Layers in each model
array[1..NUM_MODELS] of int: NUM_CONSTRAINTS = [4, 4, 5];  % Constraints per model
array[1..NUM_MODELS] of bool: HAS_OPTIMIZATION = [true, true, true];
array[1..NUM_MODELS] of bool: USES_POWER_OF_2 = [true, true, false];
array[1..NUM_MODELS] of bool: USES_PERIODICITY = [false, true, false];

% Decision variables: Which model to use for which problem?
enum ProblemType = {BINARY_STRUCTURE, BUILD_SCHEDULE, META_REASONING};
array[ProblemType] of var 1..NUM_MODELS: best_model;

% Constraint 1: Binary structure problems → Monster model
constraint best_model[BINARY_STRUCTURE] = 1;  % prove_monster_nix_store

% Constraint 2: Build scheduling → Build schedule model
constraint best_model[BUILD_SCHEDULE] = 2;  % build_schedule

% Constraint 3: Meta-reasoning → This model!
constraint best_model[META_REASONING] = 3;  % meta_minizinc

% Constraint 4: Models with more layers handle more complexity
constraint forall(p in ProblemType)(
    NUM_LAYERS[best_model[p]] >= 3  % Minimum complexity threshold
);

% Constraint 5: Self-reference - this model reasons about itself!
constraint best_model[META_REASONING] = 3;  % Fixed point!

% Pattern recognition: Extract common structure
var int: common_pattern_count = 
    sum(m in 1..NUM_MODELS)(
        bool2int(HAS_OPTIMIZATION[m]) +
        bool2int(USES_POWER_OF_2[m]) +
        bool2int(USES_PERIODICITY[m])
    );

% Meta-property: How many models use each pattern?
var int: optimization_users = sum(m in 1..NUM_MODELS)(bool2int(HAS_OPTIMIZATION[m]));
var int: power_of_2_users = sum(m in 1..NUM_MODELS)(bool2int(USES_POWER_OF_2[m]));
var int: periodicity_users = sum(m in 1..NUM_MODELS)(bool2int(USES_PERIODICITY[m]));

% Objective: Maximize pattern reuse (learn from existing models)
solve maximize common_pattern_count;

output [
    "🧠 Meta-MiniZinc Reasoning\n\n",
    "Models analyzed: \(NUM_MODELS)\n\n",
    "Pattern Usage:\n",
    "  Optimization: \(optimization_users)/\(NUM_MODELS) models\n",
    "  Power of 2: \(power_of_2_users)/\(NUM_MODELS) models\n",
    "  Periodicity: \(periodicity_users)/\(NUM_MODELS) models\n\n",
    "Problem → Model Mapping:\n",
    "  Binary Structure → \(MODEL_NAME[best_model[BINARY_STRUCTURE]])\n",
    "  Build Schedule → \(MODEL_NAME[best_model[BUILD_SCHEDULE]])\n",
    "  Meta-Reasoning → \(MODEL_NAME[best_model[META_REASONING]])\n\n",
    "Self-Reference: \(if best_model[META_REASONING] = 3 then \"✓ Fixed point!\" else \"✗ Inconsistent\" endif)\n",
    "\nCommon patterns found: \(common_pattern_count)\n"
];
