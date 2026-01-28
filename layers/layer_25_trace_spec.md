# Perf Trace Specification - Layer 25

## Expected Metrics

- **Cycles**: 32250
- **Instructions**: 19350
- **Cache misses**: 3225
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_25.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_25 > layers/layer_25_output.txt 2> layers/layer_25_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 32250
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 31 (genus 0)
- Curve: E_31
- LMFDB: conductor=31
