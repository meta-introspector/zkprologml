# Perf Trace Specification - Layer 55

## Expected Metrics

- **Cycles**: 86250
- **Instructions**: 51750
- **Cache misses**: 8625
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_55.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_55 > layers/layer_55_output.txt 2> layers/layer_55_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 86250
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 31 (genus 0)
- Curve: E_31
- LMFDB: conductor=31
