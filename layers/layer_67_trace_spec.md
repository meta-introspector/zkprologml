# Perf Trace Specification - Layer 67

## Expected Metrics

- **Cycles**: 112890
- **Instructions**: 67734
- **Cache misses**: 11289
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_67.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_67 > layers/layer_67_output.txt 2> layers/layer_67_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 112890
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 19 (genus 0)
- Curve: E_19
- LMFDB: conductor=19
