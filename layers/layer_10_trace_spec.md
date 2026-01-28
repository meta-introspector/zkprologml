# Perf Trace Specification - Layer 10

## Expected Metrics

- **Cycles**: 12000
- **Instructions**: 7200
- **Cache misses**: 1200
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_10.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_10 > layers/layer_10_output.txt 2> layers/layer_10_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 12000
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 31 (genus 0)
- Curve: E_31
- LMFDB: conductor=31
