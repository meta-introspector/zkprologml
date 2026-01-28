# Expected Output - Layer 20

## Computation Result

```
Layer 20: prime=13, sub_level=1, cycles=25000
Result: <deterministic hash>
```

## Properties

- **Deterministic**: Same input → same output
- **Verifiable**: Hash matches expected
- **Traceable**: Perf metrics match spec

## Monster Genus 0 Mapping

- Layer 20 → Prime 13 → Curve E_13
- Complexity: 25000 cycles
- Sub-level: 1

## Verification

```bash
./result/bin/layer_20 | sha256sum
# Should match: <expected_hash>
```
