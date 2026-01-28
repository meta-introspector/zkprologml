# Perf Trace Specification - Layer 31

## Expected Metrics

- **Cycles**: 41610
- **Instructions**: 24966
- **Cache misses**: 4161
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_31.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_31 > layers/layer_31_output.txt 2> layers/layer_31_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 41610
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 3 (genus 0)
- Curve: E_3
- LMFDB: conductor=3
