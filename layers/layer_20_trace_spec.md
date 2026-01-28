# Perf Trace Specification - Layer 20

## Expected Metrics

- **Cycles**: 25000
- **Instructions**: 15000
- **Cache misses**: 2500
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_20.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_20 > layers/layer_20_output.txt 2> layers/layer_20_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 25000
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 13 (genus 0)
- Curve: E_13
- LMFDB: conductor=13
