# Perf Trace Specification - Layer 38

## Expected Metrics

- **Cycles**: 53440
- **Instructions**: 32064
- **Cache misses**: 5344
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_38.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_38 > layers/layer_38_output.txt 2> layers/layer_38_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 53440
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 23 (genus 0)
- Curve: E_23
- LMFDB: conductor=23
