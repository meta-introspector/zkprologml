# Perf Trace Specification - Layer 56

## Expected Metrics

- **Cycles**: 88360
- **Instructions**: 53016
- **Cache misses**: 8836
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_56.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_56 > layers/layer_56_output.txt 2> layers/layer_56_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 88360
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 41 (genus 0)
- Curve: E_41
- LMFDB: conductor=41
