# Perf Trace Specification - Layer 15

## Expected Metrics

- **Cycles**: 18250
- **Instructions**: 10950
- **Cache misses**: 1825
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_15.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_15 > layers/layer_15_output.txt 2> layers/layer_15_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 18250
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 2 (genus 0)
- Curve: E_2
- LMFDB: conductor=2
