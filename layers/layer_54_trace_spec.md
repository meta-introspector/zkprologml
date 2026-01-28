# Perf Trace Specification - Layer 54

## Expected Metrics

- **Cycles**: 84160
- **Instructions**: 50496
- **Cache misses**: 8416
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_54.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_54 > layers/layer_54_output.txt 2> layers/layer_54_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 84160
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 29 (genus 0)
- Curve: E_29
- LMFDB: conductor=29
