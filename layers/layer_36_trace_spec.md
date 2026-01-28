# Perf Trace Specification - Layer 36

## Expected Metrics

- **Cycles**: 49960
- **Instructions**: 29976
- **Cache misses**: 4996
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_36.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_36 > layers/layer_36_output.txt 2> layers/layer_36_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 49960
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 17 (genus 0)
- Curve: E_17
- LMFDB: conductor=17
