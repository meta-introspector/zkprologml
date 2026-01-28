# Perf Trace Specification - Layer 60

## Expected Metrics

- **Cycles**: 97000
- **Instructions**: 58200
- **Cache misses**: 9700
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_60.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_60 > layers/layer_60_output.txt 2> layers/layer_60_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 97000
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 2 (genus 0)
- Curve: E_2
- LMFDB: conductor=2
