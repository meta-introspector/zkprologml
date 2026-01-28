# Perf Trace Specification - Layer 9

## Expected Metrics

- **Cycles**: 10810
- **Instructions**: 6486
- **Cache misses**: 1081
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_9.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_9 > layers/layer_9_output.txt 2> layers/layer_9_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 10810
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 29 (genus 0)
- Curve: E_29
- LMFDB: conductor=29
