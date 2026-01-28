# Perf Trace Specification - Layer 30

## Expected Metrics

- **Cycles**: 40000
- **Instructions**: 24000
- **Cache misses**: 4000
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_30.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_30 > layers/layer_30_output.txt 2> layers/layer_30_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 40000
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 2 (genus 0)
- Curve: E_2
- LMFDB: conductor=2
