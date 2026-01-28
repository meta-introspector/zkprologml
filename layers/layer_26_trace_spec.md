# Perf Trace Specification - Layer 26

## Expected Metrics

- **Cycles**: 33760
- **Instructions**: 20256
- **Cache misses**: 3376
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_26.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_26 > layers/layer_26_output.txt 2> layers/layer_26_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 33760
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 41 (genus 0)
- Curve: E_41
- LMFDB: conductor=41
