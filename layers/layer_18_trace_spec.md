# Perf Trace Specification - Layer 18

## Expected Metrics

- **Cycles**: 22240
- **Instructions**: 13344
- **Cache misses**: 2224
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_18.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_18 > layers/layer_18_output.txt 2> layers/layer_18_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 22240
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 7 (genus 0)
- Curve: E_7
- LMFDB: conductor=7
