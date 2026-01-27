#!/bin/bash
set -e

echo "📦 Committing current state..."

# Add all files
git add *.rs *.md *.parquet *.txt *.sh layers/ 2>/dev/null || true

# Commit
git commit -m "feat: Meta-lattice framework with P×N×M sampling

- 40 Rust tools for search, lattice, proof, analysis
- 8 parquet files indexing 17,651 files  
- P×N×M lattice: 15 primes × 4 n-grams × 24 chords
- 72 layer generators (360 files total)
- Kurt, Umberto, Urania, Athena pantheon
- File index and categorization complete

Status: Framework built, not yet proven
Next: Deduplicate and verify" || echo "Nothing to commit or already committed"

echo ""
echo "🧹 Starting deduplication..."
echo ""

# Remove duplicates based on analysis
echo "Removing superseded files..."

# Athena-specific superseded by collect_all
[ -f athena_to_parquet.rs ] && git rm athena_to_parquet.rs && echo "  ✓ Removed athena_to_parquet.rs"

# Old layer generator
[ -f generate_71_layers.rs ] && git rm generate_71_layers.rs && echo "  ✓ Removed generate_71_layers.rs"

# Simple proof superseded
[ -f simple_proof.rs ] && git rm simple_proof.rs && echo "  ✓ Removed simple_proof.rs"

# Old search method
[ -f search_plocate_terms.rs ] && git rm search_plocate_terms.rs && echo "  ✓ Removed search_plocate_terms.rs"

echo ""
echo "✅ Deduplication complete!"
echo ""
echo "Remaining files:"
ls -1 *.rs | wc -l
