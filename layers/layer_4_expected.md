# Expected Output - Layer 4

## Computation Result

```
Layer 4: prime=11, sub_level=0, cycles=5160
Result: <deterministic hash>
```

## Properties

- **Deterministic**: Same input → same output
- **Verifiable**: Hash matches expected
- **Traceable**: Perf metrics match spec

## Monster Genus 0 Mapping

- Layer 4 → Prime 11 → Curve E_11
- Complexity: 5160 cycles
- Sub-level: 0

## Verification

```bash
./result/bin/layer_4 | sha256sum
# Should match: <expected_hash>
```
