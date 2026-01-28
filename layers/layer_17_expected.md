# Expected Output - Layer 17

## Computation Result

```
Layer 17: prime=5, sub_level=1, cycles=20890
Result: <deterministic hash>
```

## Properties

- **Deterministic**: Same input → same output
- **Verifiable**: Hash matches expected
- **Traceable**: Perf metrics match spec

## Monster Genus 0 Mapping

- Layer 17 → Prime 5 → Curve E_5
- Complexity: 20890 cycles
- Sub-level: 1

## Verification

```bash
./result/bin/layer_17 | sha256sum
# Should match: <expected_hash>
```
