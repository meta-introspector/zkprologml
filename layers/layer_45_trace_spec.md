# Perf Trace Specification - Layer 45

## Expected Metrics

- **Cycles**: 66250
- **Instructions**: 39750
- **Cache misses**: 6625
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_45.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_45 > layers/layer_45_output.txt 2> layers/layer_45_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 66250
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 2 (genus 0)
- Curve: E_2
- LMFDB: conductor=2
