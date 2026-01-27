# MiniZinc Expert System Knowledge Base

## Discovered Resources

### MiniZinc Models (1 files)

1. `/mnt/data1/meta-introspector/minizinc/prove_monster_nix_store.mzn`

### Rust Integration (0 files)


### Nix Integration (0 files)


## Learned Patterns


## Expert Rules (Learned)

```prolog
% Rule 1: If problem has optimization, use MiniZinc
use_minizinc(Problem) :- has_constraints(Problem), needs_optimization(Problem).

% Rule 2: If MiniZinc exists, wrap in Nix for reproducibility
use_nix(MznFile) :- exists(MznFile), needs_reproducible_build.

% Rule 3: If Nix builds MiniZinc, Rust can parse results
use_rust(NixBuild) :- builds_minizinc(NixBuild), needs_parsing.

% Rule 4: Bott periodicity reduces search space
optimize(Levels) :- period(8), Levels mod 8 = Pattern, solve(Pattern).
```

## Self-Learning System

### Training Data

- **Input**: 1 MiniZinc models
- **Context**: 0 Rust + 0 Nix integrations
- **Total examples**: 1

### Learning Algorithm

1. **Pattern Recognition**: Extract common structures from .mzn files
2. **Usage Analysis**: Map how Rust/Nix invoke MiniZinc
3. **Rule Induction**: Generate expert rules from patterns
4. **Validation**: Test rules against known examples
5. **Refinement**: Update rules based on success rate

### Next Iteration

- Parse actual .mzn files to extract constraints
- Analyze Rust code to find MiniZinc invocation patterns
- Build decision tree: Problem → MiniZinc Model → Nix Build → Rust Parse
- Train on our own system: 72 layers, 8 patterns, Bott periodicity

