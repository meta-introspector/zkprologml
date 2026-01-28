# Perf Trace Specification - Layer 28

## Expected Metrics

- **Cycles**: 36840
- **Instructions**: 22104
- **Cache misses**: 3684
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_28.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_28 > layers/layer_28_output.txt 2> layers/layer_28_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 36840
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 59 (genus 0)
- Curve: E_59
- LMFDB: conductor=59
