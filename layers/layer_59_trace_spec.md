# Perf Trace Specification - Layer 59

## Expected Metrics

- **Cycles**: 94810
- **Instructions**: 56886
- **Cache misses**: 9481
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_59.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_59 > layers/layer_59_output.txt 2> layers/layer_59_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 94810
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 71 (genus 0)
- Curve: E_71
- LMFDB: conductor=71
