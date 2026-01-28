# Expected Output - Layer 14

## Computation Result

```
Layer 14: prime=71, sub_level=0, cycles=16960
Result: <deterministic hash>
```

## Properties

- **Deterministic**: Same input → same output
- **Verifiable**: Hash matches expected
- **Traceable**: Perf metrics match spec

## Monster Genus 0 Mapping

- Layer 14 → Prime 71 → Curve E_71
- Complexity: 16960 cycles
- Sub-level: 0

## Verification

```bash
./result/bin/layer_14 | sha256sum
# Should match: <expected_hash>
```
