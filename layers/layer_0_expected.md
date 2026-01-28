# Expected Output - Layer 0

## Computation Result

```
Layer 0: prime=2, sub_level=0, cycles=1000
Result: <deterministic hash>
```

## Properties

- **Deterministic**: Same input → same output
- **Verifiable**: Hash matches expected
- **Traceable**: Perf metrics match spec

## Monster Genus 0 Mapping

- Layer 0 → Prime 2 → Curve E_2
- Complexity: 1000 cycles
- Sub-level: 0

## Verification

```bash
./result/bin/layer_0 | sha256sum
# Should match: <expected_hash>
```
