# Perf Trace Specification - Layer 44

## Expected Metrics

- **Cycles**: 64360
- **Instructions**: 38616
- **Cache misses**: 6436
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_44.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_44 > layers/layer_44_output.txt 2> layers/layer_44_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 64360
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 71 (genus 0)
- Curve: E_71
- LMFDB: conductor=71
