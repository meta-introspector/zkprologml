# Perf Trace Specification - Layer 16

## Expected Metrics

- **Cycles**: 19560
- **Instructions**: 11736
- **Cache misses**: 1956
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_16.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_16 > layers/layer_16_output.txt 2> layers/layer_16_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 19560
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 3 (genus 0)
- Curve: E_3
- LMFDB: conductor=3
