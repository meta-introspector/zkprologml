# Perf Trace Specification - Layer 14

## Expected Metrics

- **Cycles**: 16960
- **Instructions**: 10176
- **Cache misses**: 1696
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_14.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_14 > layers/layer_14_output.txt 2> layers/layer_14_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 16960
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 71 (genus 0)
- Curve: E_71
- LMFDB: conductor=71
