# Perf Trace Specification - Layer 58

## Expected Metrics

- **Cycles**: 92640
- **Instructions**: 55584
- **Cache misses**: 9264
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_58.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_58 > layers/layer_58_output.txt 2> layers/layer_58_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 92640
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 59 (genus 0)
- Curve: E_59
- LMFDB: conductor=59
