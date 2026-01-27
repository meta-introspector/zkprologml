# Program Data Flow Documentation

## Calculated Statistics

- **Terms**: 11524 keywords
- **Parquets**: 8 files, 5.5 MB
- **Chords**: 111 files, 4.4 MB
- **Layers**: 361 files, 0.2 MB
- **Proofs**: 7 files, 32 KB
- **Docs**: 41 files, 185 KB

**Total: 10.3 MB**

## Data Flow

```
Terms (11524) → Plocate → Parquets (8 files)
         ↓
      Extract → Rank → Terms (feedback)
         ↓
      P×N×M Lattice
         ↓
      Analysis → Proofs (7 Lean files)
```
