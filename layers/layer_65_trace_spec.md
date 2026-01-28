# Perf Trace Specification - Layer 65

## Expected Metrics

- **Cycles**: 108250
- **Instructions**: 64950
- **Cache misses**: 10825
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_65.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_65 > layers/layer_65_output.txt 2> layers/layer_65_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 108250
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 13 (genus 0)
- Curve: E_13
- LMFDB: conductor=13
