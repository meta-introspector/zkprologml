# Perf Trace Specification - Layer 52

## Expected Metrics

- **Cycles**: 80040
- **Instructions**: 48024
- **Cache misses**: 8004
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_52.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_52 > layers/layer_52_output.txt 2> layers/layer_52_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 80040
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 19 (genus 0)
- Curve: E_19
- LMFDB: conductor=19
