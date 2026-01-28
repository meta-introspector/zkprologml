# Perf Trace Specification - Layer 4

## Expected Metrics

- **Cycles**: 5160
- **Instructions**: 3096
- **Cache misses**: 516
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_4.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_4 > layers/layer_4_output.txt 2> layers/layer_4_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 5160
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 11 (genus 0)
- Curve: E_11
- LMFDB: conductor=11
