#!/usr/bin/env bash
# boot.sh - Bootstrap zkPrologML system

echo ""
echo "♾️  zkPrologML Bootstrap"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Run boot.pl
swipl -g boot -t halt boot.pl

echo ""
echo "🌌 Entering zkPrologML environment..."
echo ""

# Enter Nix shell with all dependencies
nix develop
