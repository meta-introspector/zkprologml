#!/bin/bash
# audit_constants.sh - Find all hardcoded constants

echo "🧹 AUDIT: Remove duplicate hardcoded data"
echo "═══════════════════════════════════════════════════════════"
echo

cd /mnt/data1/nix/vendor/rust/github/data/proofs

# Create output
mkdir -p generated
OUT="generated/all_constants.csv"
echo "file,type,line,value" > "$OUT"

# Extract Rust constants
echo "🔍 Extracting Rust constants..."
find . -name "*.rs" -type f 2>/dev/null | while read f; do
    grep -n "^const " "$f" 2>/dev/null | while IFS=: read line code; do
        echo "$f,rust_const,$line,\"$code\"" >> "$OUT"
    done
done

# Extract Prolog facts (first 100 per file)
echo "🔍 Extracting Prolog facts..."
find . -name "*.pl" -type f 2>/dev/null | while read f; do
    grep -n "^[a-z_]*(" "$f" 2>/dev/null | grep -v ":-" | head -100 | while IFS=: read line code; do
        echo "$f,prolog_fact,$line,\"$code\"" >> "$OUT"
    done
done

# Extract Lean4 constants
echo "🔍 Extracting Lean4 constants..."
find . -name "*.lean" -type f 2>/dev/null | while read f; do
    grep -n "^def.*:=.*[0-9]" "$f" 2>/dev/null | while IFS=: read line code; do
        echo "$f,lean_const,$line,\"$code\"" >> "$OUT"
    done
done

# Count
TOTAL=$(tail -n +2 "$OUT" | wc -l)
echo
echo "📊 STATISTICS"
echo "═══════════════════════════════════════════════════════════"
echo "  Total constants: $TOTAL"
echo "  Rust: $(grep ",rust_const," "$OUT" | wc -l)"
echo "  Prolog: $(grep ",prolog_fact," "$OUT" | wc -l)"
echo "  Lean4: $(grep ",lean_const," "$OUT" | wc -l)"

# Find duplicates
echo
echo "🔧 Finding duplicates..."
UNIQUE=$(tail -n +2 "$OUT" | cut -d, -f4 | sort -u | wc -l)
DUPS=$((TOTAL - UNIQUE))
SAVINGS=$(echo "scale=2; $DUPS * 100 / $TOTAL" | bc)

echo "  Unique values: $UNIQUE"
echo "  Duplicates: $DUPS ($SAVINGS%)"

# Save unique
tail -n +2 "$OUT" | cut -d, -f4 | sort -u > generated/unique_constants.txt

echo
echo "✅ AUDIT COMPLETE"
echo "  📄 All constants: $OUT"
echo "  📄 Unique values: generated/unique_constants.txt"
