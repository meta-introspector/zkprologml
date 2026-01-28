# Perf Trace Specification - Layer 71

## Expected Metrics

- **Cycles**: 122410
- **Instructions**: 73446
- **Cache misses**: 12241
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_71.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_71 > layers/layer_71_output.txt 2> layers/layer_71_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 122410
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 41 (genus 0)
- Curve: E_41
- LMFDB: conductor=41
