# Perf Trace Specification - Layer 39

## Expected Metrics

- **Cycles**: 55210
- **Instructions**: 33126
- **Cache misses**: 5521
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_39.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_39 > layers/layer_39_output.txt 2> layers/layer_39_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 55210
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 29 (genus 0)
- Curve: E_29
- LMFDB: conductor=29
