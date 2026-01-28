# Perf Trace Specification - Layer 22

## Expected Metrics

- **Cycles**: 27840
- **Instructions**: 16704
- **Cache misses**: 2784
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_22.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_22 > layers/layer_22_output.txt 2> layers/layer_22_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 27840
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 19 (genus 0)
- Curve: E_19
- LMFDB: conductor=19
