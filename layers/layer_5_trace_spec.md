# Perf Trace Specification - Layer 5

## Expected Metrics

- **Cycles**: 6250
- **Instructions**: 3750
- **Cache misses**: 625
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_5.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_5 > layers/layer_5_output.txt 2> layers/layer_5_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 6250
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 13 (genus 0)
- Curve: E_13
- LMFDB: conductor=13
