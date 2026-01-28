# Perf Trace Specification - Layer 43

## Expected Metrics

- **Cycles**: 62490
- **Instructions**: 37494
- **Cache misses**: 6249
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_43.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_43 > layers/layer_43_output.txt 2> layers/layer_43_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 62490
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 59 (genus 0)
- Curve: E_59
- LMFDB: conductor=59
