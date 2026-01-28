# Perf Trace Specification - Layer 3

## Expected Metrics

- **Cycles**: 4090
- **Instructions**: 2454
- **Cache misses**: 409
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_3.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_3 > layers/layer_3_output.txt 2> layers/layer_3_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 4090
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 7 (genus 0)
- Curve: E_7
- LMFDB: conductor=7
