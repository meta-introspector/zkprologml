# Perf Trace Specification - Layer 32

## Expected Metrics

- **Cycles**: 43240
- **Instructions**: 25944
- **Cache misses**: 4324
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_32.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_32 > layers/layer_32_output.txt 2> layers/layer_32_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 43240
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 5 (genus 0)
- Curve: E_5
- LMFDB: conductor=5
