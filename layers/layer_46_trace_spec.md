# Perf Trace Specification - Layer 46

## Expected Metrics

- **Cycles**: 68160
- **Instructions**: 40896
- **Cache misses**: 6816
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_46.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_46 > layers/layer_46_output.txt 2> layers/layer_46_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 68160
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 3 (genus 0)
- Curve: E_3
- LMFDB: conductor=3
