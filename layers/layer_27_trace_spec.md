# Perf Trace Specification - Layer 27

## Expected Metrics

- **Cycles**: 35290
- **Instructions**: 21174
- **Cache misses**: 3529
- **IPC**: 0.600

## Command

```bash
nix-build layers/layer_27.nix
perf stat -e cycles,instructions,cache-misses ./result/bin/layer_27 > layers/layer_27_output.txt 2> layers/layer_27_perf.txt
```

## Verification

Compare actual trace to expected:
- Cycles within 10% of 35290
- IPC approximately 0.6
- Result deterministic

## Monster Prime Mapping

- Prime: 47 (genus 0)
- Curve: E_47
- LMFDB: conductor=47
