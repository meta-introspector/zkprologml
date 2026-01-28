# Perf Trace Specification - Layer 51

## Expected Metrics

- **Cycles**: 78010
- **Instructions**: 46806
- **Cache misses**: 7801
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_51.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_51 > layers/layer_51_output.txt 2> layers/layer_51_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 78010
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 17 (genus 0)
- Curve: E_17
- LMFDB: conductor=17
