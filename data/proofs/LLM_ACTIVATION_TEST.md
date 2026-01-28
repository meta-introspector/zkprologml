# LLM Activation Lattice Test - RUNNING

**Status**: 🟢 Background process active (PID: 1106104)

## Concept

Feed each Gödel-numbered program to LLM (qwen2.5-coder:7b) and trace:
1. **Activation patterns** - Which complexity levels the LLM mentions
2. **Response characteristics** - Length, duration, content
3. **Introspection differences** - How LLM perceives different complexity levels

## Test Matrix

| Gödel | Prime | Complexity | Program |
|-------|-------|------------|---------|
| 2 | 2 | Types | `test_2_1.c` |
| 3 | 3 | Operators | `test_3_1.c` |
| 5 | 5 | Variables | `test_5_1.c` |
| 7 | 7 | Control flow | `test_7_1.c` |
| 11 | 11 | Functions | `test_11_1.c` |

## Hypothesis

**Different complexity levels produce different LLM activation patterns.**

- Simple programs (2, 3) → Focus on basic operations
- Medium programs (5, 7) → Focus on data flow and control
- Complex programs (11+) → Focus on structure and semantics

## Outputs

1. **`llm_activations_<timestamp>.pl`** - Prolog facts with results
2. **`activation_matrix.csv`** - Gödel × Prime activation counts
3. **`perf_llm_activation.data`** - Perf trace of entire test

## Analysis Plan

Once complete:
1. Compare activation patterns across complexity levels
2. Map LLM introspection to Monster group elements
3. Prove: `LLM_activation(g • p) = g • LLM_activation(p)` (group action)
4. Show LLM "sees" the prime lattice structure

## Monitor

```bash
./monitor_llm_activation.sh
```

## Current Progress

- ✅ Started background test
- ⏳ Processing program 3 (operators)
- ⏳ Waiting for LLM responses (can take 30-60s each)
- ⏳ 4 more programs to test

**Expected completion**: ~5-10 minutes (depends on LLM speed)

---

**Started**: 2026-01-28T06:16
**Log**: `generated/llm_activation.log`
**Perf**: `generated/perf_llm_activation.data`
