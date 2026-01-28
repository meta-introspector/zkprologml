# Perf Trace Specification - Layer 50

## Expected Metrics

- **Cycles**: 76000
- **Instructions**: 45600
- **Cache misses**: 7600
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_50.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_50 > layers/layer_50_output.txt 2> layers/layer_50_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 76000
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 13 (genus 0)
- Curve: E_13
- LMFDB: conductor=13
