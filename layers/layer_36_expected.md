# Expected Output - Layer 36

## Computation Result

```
Layer 36: prime=17, sub_level=2, cycles=49960
Result: <deterministic hash>
```

## Properties

- **Deterministic**: Same input → same output
- **Verifiable**: Hash matches expected
- **Traceable**: Perf metrics match spec

## Monster Genus 0 Mapping

- Layer 36 → Prime 17 → Curve E_17
- Complexity: 49960 cycles
- Sub-level: 2

## Verification

```bash
./result/bin/layer_36 | sha256sum
# Should match: <expected_hash>
```
