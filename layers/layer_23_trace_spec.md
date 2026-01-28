# Perf Trace Specification - Layer 23

## Expected Metrics

- **Cycles**: 29290
- **Instructions**: 17574
- **Cache misses**: 2929
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_23.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_23 > layers/layer_23_output.txt 2> layers/layer_23_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 29290
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 23 (genus 0)
- Curve: E_23
- LMFDB: conductor=23
