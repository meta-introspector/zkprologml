# Perf Trace Specification - Layer 34

## Expected Metrics

- **Cycles**: 46560
- **Instructions**: 27936
- **Cache misses**: 4656
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_34.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_34 > layers/layer_34_output.txt 2> layers/layer_34_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 46560
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 11 (genus 0)
- Curve: E_11
- LMFDB: conductor=11
