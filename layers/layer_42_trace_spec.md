# Perf Trace Specification - Layer 42

## Expected Metrics

- **Cycles**: 60640
- **Instructions**: 36384
- **Cache misses**: 6064
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_42.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_42 > layers/layer_42_output.txt 2> layers/layer_42_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 60640
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 47 (genus 0)
- Curve: E_47
- LMFDB: conductor=47
