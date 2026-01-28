# Perf Trace Specification - Layer 0

## Expected Metrics

- **Cycles**: 1000
- **Instructions**: 600
- **Cache misses**: 100
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_0.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_0 > layers/layer_0_output.txt 2> layers/layer_0_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 1000
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 2 (genus 0)
- Curve: E_2
- LMFDB: conductor=2
