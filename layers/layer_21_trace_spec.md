# Perf Trace Specification - Layer 21

## Expected Metrics

- **Cycles**: 26410
- **Instructions**: 15846
- **Cache misses**: 2641
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_21.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_21 > layers/layer_21_output.txt 2> layers/layer_21_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 26410
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 17 (genus 0)
- Curve: E_17
- LMFDB: conductor=17
