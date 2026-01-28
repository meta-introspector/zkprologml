# Perf Trace Specification - Layer 6

## Expected Metrics

- **Cycles**: 7360
- **Instructions**: 4416
- **Cache misses**: 736
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_6.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_6 > layers/layer_6_output.txt 2> layers/layer_6_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 7360
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 17 (genus 0)
- Curve: E_17
- LMFDB: conductor=17
