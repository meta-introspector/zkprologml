# Expected Output - Layer 6

## Computation Result

```
Layer 6: prime=17, sub_level=0, cycles=7360
Result: <deterministic hash>
```

## Properties

- **Deterministic**: Same input → same output
- **Verifiable**: Hash matches expected
- **Traceable**: Perf metrics match spec

## Monster Genus 0 Mapping

- Layer 6 → Prime 17 → Curve E_17
- Complexity: 7360 cycles
- Sub-level: 0

## Verification

```bash
./result/bin/layer_6 | sha256sum
# Should match: <expected_hash>
```
