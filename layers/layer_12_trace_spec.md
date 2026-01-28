# Perf Trace Specification - Layer 12

## Expected Metrics

- **Cycles**: 14440
- **Instructions**: 8664
- **Cache misses**: 1444
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_12.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_12 > layers/layer_12_output.txt 2> layers/layer_12_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 14440
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 47 (genus 0)
- Curve: E_47
- LMFDB: conductor=47
