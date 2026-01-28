# Expected Output - Layer 44

## Computation Result

```
Layer 44: prime=71, sub_level=2, cycles=64360
Result: <deterministic hash>
```

## Properties

- **Deterministic**: Same input → same output
- **Verifiable**: Hash matches expected
- **Traceable**: Perf metrics match spec

## Monster Genus 0 Mapping

- Layer 44 → Prime 71 → Curve E_71
- Complexity: 64360 cycles
- Sub-level: 2

## Verification

```bash
./result/bin/layer_44 | sha256sum
# Should match: <expected_hash>
```
