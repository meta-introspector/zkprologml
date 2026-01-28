# Perf Trace Specification - Layer 1

## Expected Metrics

- **Cycles**: 2010
- **Instructions**: 1206
- **Cache misses**: 201
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_1.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_1 > layers/layer_1_output.txt 2> layers/layer_1_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 2010
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 3 (genus 0)
- Curve: E_3
- LMFDB: conductor=3
