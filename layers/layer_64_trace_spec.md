# Perf Trace Specification - Layer 64

## Expected Metrics

- **Cycles**: 105960
- **Instructions**: 63576
- **Cache misses**: 10596
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_64.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_64 > layers/layer_64_output.txt 2> layers/layer_64_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 105960
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 11 (genus 0)
- Curve: E_11
- LMFDB: conductor=11
