# Perf Trace Specification - Layer 47

## Expected Metrics

- **Cycles**: 70090
- **Instructions**: 42054
- **Cache misses**: 7009
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_47.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_47 > layers/layer_47_output.txt 2> layers/layer_47_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 70090
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 5 (genus 0)
- Curve: E_5
- LMFDB: conductor=5
