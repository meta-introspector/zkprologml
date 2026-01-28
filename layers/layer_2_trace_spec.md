# Perf Trace Specification - Layer 2

## Expected Metrics

- **Cycles**: 3040
- **Instructions**: 1824
- **Cache misses**: 304
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_2.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_2 > layers/layer_2_output.txt 2> layers/layer_2_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 3040
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 5 (genus 0)
- Curve: E_5
- LMFDB: conductor=5
