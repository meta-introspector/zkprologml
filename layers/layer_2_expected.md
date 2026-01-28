# Expected Output - Layer 2

## Computation Result

```
Layer 2: prime=5, sub_level=0, cycles=3040
Result: <deterministic hash>
```

## Properties

- **Deterministic**: Same input → same output
- **Verifiable**: Hash matches expected
- **Traceable**: Perf metrics match spec

## Monster Genus 0 Mapping

- Layer 2 → Prime 5 → Curve E_5
- Complexity: 3040 cycles
- Sub-level: 0

## Verification

```bash
./result/bin/layer_2 | sha256sum
# Should match: <expected_hash>
```
