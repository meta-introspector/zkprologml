# Perf Trace Specification - Layer 11

## Expected Metrics

- **Cycles**: 13210
- **Instructions**: 7926
- **Cache misses**: 1321
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_11.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_11 > layers/layer_11_output.txt 2> layers/layer_11_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 13210
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 41 (genus 0)
- Curve: E_41
- LMFDB: conductor=41
