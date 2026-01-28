# Perf Trace Specification - Layer 13

## Expected Metrics

- **Cycles**: 15690
- **Instructions**: 9414
- **Cache misses**: 1569
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_13.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_13 > layers/layer_13_output.txt 2> layers/layer_13_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 15690
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 59 (genus 0)
- Curve: E_59
- LMFDB: conductor=59
