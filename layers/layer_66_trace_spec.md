# Perf Trace Specification - Layer 66

## Expected Metrics

- **Cycles**: 110560
- **Instructions**: 66336
- **Cache misses**: 11056
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_66.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_66 > layers/layer_66_output.txt 2> layers/layer_66_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 110560
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 17 (genus 0)
- Curve: E_17
- LMFDB: conductor=17
