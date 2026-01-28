# Perf Trace Specification - Layer 63

## Expected Metrics

- **Cycles**: 103690
- **Instructions**: 62214
- **Cache misses**: 10369
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_63.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_63 > layers/layer_63_output.txt 2> layers/layer_63_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 103690
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 7 (genus 0)
- Curve: E_7
- LMFDB: conductor=7
