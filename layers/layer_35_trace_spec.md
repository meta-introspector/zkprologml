# Perf Trace Specification - Layer 35

## Expected Metrics

- **Cycles**: 48250
- **Instructions**: 28950
- **Cache misses**: 4825
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_35.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_35 > layers/layer_35_output.txt 2> layers/layer_35_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 48250
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 13 (genus 0)
- Curve: E_13
- LMFDB: conductor=13
