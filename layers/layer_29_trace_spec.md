# Perf Trace Specification - Layer 29

## Expected Metrics

- **Cycles**: 38410
- **Instructions**: 23046
- **Cache misses**: 3841
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_29.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_29 > layers/layer_29_output.txt 2> layers/layer_29_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 38410
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 71 (genus 0)
- Curve: E_71
- LMFDB: conductor=71
