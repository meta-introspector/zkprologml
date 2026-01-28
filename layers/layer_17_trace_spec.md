# Perf Trace Specification - Layer 17

## Expected Metrics

- **Cycles**: 20890
- **Instructions**: 12534
- **Cache misses**: 2089
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_17.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_17 > layers/layer_17_output.txt 2> layers/layer_17_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 20890
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 5 (genus 0)
- Curve: E_5
- LMFDB: conductor=5
