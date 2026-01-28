# Perf Trace Specification - Layer 24

## Expected Metrics

- **Cycles**: 30760
- **Instructions**: 18456
- **Cache misses**: 3076
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_24.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_24 > layers/layer_24_output.txt 2> layers/layer_24_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 30760
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 29 (genus 0)
- Curve: E_29
- LMFDB: conductor=29
