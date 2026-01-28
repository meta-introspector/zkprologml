# Perf Trace Specification - Layer 70

## Expected Metrics

- **Cycles**: 120000
- **Instructions**: 72000
- **Cache misses**: 12000
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_70.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_70 > layers/layer_70_output.txt 2> layers/layer_70_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 120000
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 31 (genus 0)
- Curve: E_31
- LMFDB: conductor=31
