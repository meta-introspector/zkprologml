# Nix Build Utilities

- generate_layer_cells.rs - Generate nix derivations
- 72 layers in layers/ directory
- Each layer: .nix + .rs + specs + proofs

Usage:
  nix-build layers/layer_N.nix
