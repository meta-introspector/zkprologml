# Perf Trace Specification - Layer 37

## Expected Metrics

- **Cycles**: 51690
- **Instructions**: 31014
- **Cache misses**: 5169
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_37.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_37 > layers/layer_37_output.txt 2> layers/layer_37_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 51690
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 19 (genus 0)
- Curve: E_19
- LMFDB: conductor=19
