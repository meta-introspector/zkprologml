# Perf Trace Specification - Layer 7

## Expected Metrics

- **Cycles**: 8490
- **Instructions**: 5094
- **Cache misses**: 849
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_7.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_7 > layers/layer_7_output.txt 2> layers/layer_7_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 8490
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 19 (genus 0)
- Curve: E_19
- LMFDB: conductor=19
