# Expected Output - Layer 71

## Computation Result

```
Layer 71: prime=41, sub_level=4, cycles=122410
Result: <deterministic hash>
```

## Properties

- **Deterministic**: Same input → same output
- **Verifiable**: Hash matches expected
- **Traceable**: Perf metrics match spec

## Monster Genus 0 Mapping

- Layer 71 → Prime 41 → Curve E_41
- Complexity: 122410 cycles
- Sub-level: 4

## Verification

```bash
./result/bin/layer_71 | sha256sum
# Should match: <expected_hash>
```
