# Perf Trace Specification - Layer 41

## Expected Metrics

- **Cycles**: 58810
- **Instructions**: 35286
- **Cache misses**: 5881
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_41.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_41 > layers/layer_41_output.txt 2> layers/layer_41_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 58810
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 41 (genus 0)
- Curve: E_41
- LMFDB: conductor=41
