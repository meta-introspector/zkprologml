# Perf Trace Specification - Layer 8

## Expected Metrics

- **Cycles**: 9640
- **Instructions**: 5784
- **Cache misses**: 964
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_8.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_8 > layers/layer_8_output.txt 2> layers/layer_8_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 9640
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 23 (genus 0)
- Curve: E_23
- LMFDB: conductor=23
