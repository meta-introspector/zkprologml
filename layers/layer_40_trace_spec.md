# Perf Trace Specification - Layer 40

## Expected Metrics

- **Cycles**: 57000
- **Instructions**: 34200
- **Cache misses**: 5700
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_40.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_40 > layers/layer_40_output.txt 2> layers/layer_40_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 57000
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 31 (genus 0)
- Curve: E_31
- LMFDB: conductor=31
