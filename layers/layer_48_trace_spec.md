# Perf Trace Specification - Layer 48

## Expected Metrics

- **Cycles**: 72040
- **Instructions**: 43224
- **Cache misses**: 7204
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_48.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_48 > layers/layer_48_output.txt 2> layers/layer_48_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 72040
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 7 (genus 0)
- Curve: E_7
- LMFDB: conductor=7
