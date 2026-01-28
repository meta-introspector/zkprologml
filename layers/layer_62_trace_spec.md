# Perf Trace Specification - Layer 62

## Expected Metrics

- **Cycles**: 101440
- **Instructions**: 60864
- **Cache misses**: 10144
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_62.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_62 > layers/layer_62_output.txt 2> layers/layer_62_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 101440
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 5 (genus 0)
- Curve: E_5
- LMFDB: conductor=5
