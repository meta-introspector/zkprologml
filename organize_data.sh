#!/bin/bash
# Organize data files

echo "📊 Organizing data files..."

mkdir -p data/{parquets,chords,proofs,docs}

echo ""
echo "Parquet files:"
mv *.parquet data/parquets/ 2>/dev/null
ls data/parquets/*.parquet 2>/dev/null | wc -l | xargs echo "  ✓ Moved parquet files:"

echo ""
echo "Chord files (search results):"
mv github_*.txt search_*.txt index_*.txt data/chords/ 2>/dev/null
mv *_lattice.txt *_resonance.txt data/chords/ 2>/dev/null
ls data/chords/*.txt 2>/dev/null | wc -l | xargs echo "  ✓ Moved chord files:"

echo ""
echo "Proof files:"
mv *.lean data/proofs/ 2>/dev/null
ls data/proofs/*.lean 2>/dev/null | wc -l | xargs echo "  ✓ Moved Lean proofs:"

echo ""
echo "Documentation:"
mv *.md data/docs/ 2>/dev/null
ls data/docs/*.md 2>/dev/null | wc -l | xargs echo "  ✓ Moved markdown docs:"

echo ""
echo "Other data:"
mv *.txt data/docs/ 2>/dev/null
mv *.sh . 2>/dev/null  # Keep scripts in root

echo ""
echo "✅ Data organization complete!"
echo ""
echo "Structure:"
echo "  data/parquets/  - All .parquet files"
echo "  data/chords/    - Chord files (search results)"
echo "  data/proofs/    - Lean4 proof files"
echo "  data/docs/      - Documentation and text files"
