#!/bin/bash
# Organize files by function

mkdir -p {search,lattice,proof,analysis,cards}

# Search tools
mv *search*.rs *plocate*.rs search/ 2>/dev/null

# Lattice tools  
mv *lattice*.rs *pnm*.rs lattice/ 2>/dev/null

# Proof tools
mv *proof*.rs *lean*.rs *knuth*.rs proof/ 2>/dev/null

# Analysis tools
mv *extract*.rs *rank*.rs *orbit*.rs analysis/ 2>/dev/null

# Card system
mv *umberto*.rs *athena*.rs *urania*.rs *kurt*.rs cards/ 2>/dev/null

echo "✅ Files organized!"
