# Expected Output - Layer 41

## Computation Result

```
Layer 41: prime=41, sub_level=2, cycles=58810
Result: <deterministic hash>
```

## Properties

- **Deterministic**: Same input → same output
- **Verifiable**: Hash matches expected
- **Traceable**: Perf metrics match spec

## Monster Genus 0 Mapping

- Layer 41 → Prime 41 → Curve E_41
- Complexity: 58810 cycles
- Sub-level: 2

## Verification

```bash
./result/bin/layer_41 | sha256sum
# Should match: <expected_hash>
```
