# Perf Trace Specification - Layer 33

## Expected Metrics

- **Cycles**: 44890
- **Instructions**: 26934
- **Cache misses**: 4489
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_33.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_33 > layers/layer_33_output.txt 2> layers/layer_33_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 44890
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 7 (genus 0)
- Curve: E_7
- LMFDB: conductor=7
