# Perf Trace Specification - Layer 61

## Expected Metrics

- **Cycles**: 99210
- **Instructions**: 59526
- **Cache misses**: 9921
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_61.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_61 > layers/layer_61_output.txt 2> layers/layer_61_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 99210
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 3 (genus 0)
- Curve: E_3
- LMFDB: conductor=3
