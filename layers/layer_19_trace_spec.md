# Perf Trace Specification - Layer 19

## Expected Metrics

- **Cycles**: 23610
- **Instructions**: 14166
- **Cache misses**: 2361
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_19.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_19 > layers/layer_19_output.txt 2> layers/layer_19_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 23610
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 11 (genus 0)
- Curve: E_11
- LMFDB: conductor=11
