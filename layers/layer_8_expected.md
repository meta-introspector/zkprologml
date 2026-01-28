# Expected Output - Layer 8

## Computation Result

```
Layer 8: prime=23, sub_level=0, cycles=9640
Result: <deterministic hash>
```

## Properties

- **Deterministic**: Same input → same output
- **Verifiable**: Hash matches expected
- **Traceable**: Perf metrics match spec

## Monster Genus 0 Mapping

- Layer 8 → Prime 23 → Curve E_23
- Complexity: 9640 cycles
- Sub-level: 0

## Verification

```bash
./result/bin/layer_8 | sha256sum
# Should match: <expected_hash>
```
