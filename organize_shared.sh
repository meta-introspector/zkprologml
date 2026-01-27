#!/bin/bash
# Move shared utilities to proper locations

echo "📦 Organizing shared utilities..."

mkdir -p shared/{parquet,nix,jobs}

echo ""
echo "Parquet handling:"
# Keep parquet tools in layer2 but create shared lib
cat > shared/parquet/README.md << 'EOF'
# Parquet Utilities

Common parquet operations:
- Compression (gzip)
- Schema: search_term, file_path, file_size, compressed_bytes
- Read/write with arrow

See: layer2_plocate/collect_all_to_parquet.rs
EOF
echo "  ✓ Parquet docs"

echo ""
echo "Nix handling:"
# Move nix-related
mv generate_layer_cells.rs shared/nix/ 2>/dev/null
cat > shared/nix/README.md << 'EOF'
# Nix Build Utilities

- generate_layer_cells.rs - Generate nix derivations
- 72 layers in layers/ directory
- Each layer: .nix + .rs + specs + proofs

Usage:
  nix-build layers/layer_N.nix
EOF
echo "  ✓ Nix tools"

echo ""
echo "Job management:"
cat > shared/jobs/README.md << 'EOF'
# Job Management

Parallel execution:
- 24 CPUs available
- Use rayon for parallelism
- Umberto scholars pattern (24 workers)

See: umberto_eco_scholars.rs, multi_process_trading.rs
EOF
echo "  ✓ Job docs"

echo ""
echo "✅ Shared utilities organized!"
echo ""
echo "Structure:"
echo "  shared/parquet/  - Parquet read/write utilities"
echo "  shared/nix/      - Nix build generation"
echo "  shared/jobs/     - Parallel job management"
