# Perf Trace Specification - Layer 49

## Expected Metrics

- **Cycles**: 74010
- **Instructions**: 44406
- **Cache misses**: 7401
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_49.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_49 > layers/layer_49_output.txt 2> layers/layer_49_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 74010
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 11 (genus 0)
- Curve: E_11
- LMFDB: conductor=11
