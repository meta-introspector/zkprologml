# Perf Trace Specification - Layer 57

## Expected Metrics

- **Cycles**: 90490
- **Instructions**: 54294
- **Cache misses**: 9049
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_57.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_57 > layers/layer_57_output.txt 2> layers/layer_57_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 90490
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 47 (genus 0)
- Curve: E_47
- LMFDB: conductor=47
