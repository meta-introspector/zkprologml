#!/bin/bash
# Organize code into layers matching data flow

echo "📁 Organizing code into layers..."

# Create layer directories
mkdir -p {layer1_terms,layer2_plocate,layer3_github,layer4_gitpacks,layer5_analysis,shared}

echo ""
echo "Layer 1: Terms & Keywords"
mv ranked_terms.txt extracted_terms.txt layer1_terms/ 2>/dev/null
mv umberto_*.md layer1_terms/ 2>/dev/null
echo "  ✓ Terms and cards"

echo ""
echo "Layer 2: Plocate Search"
mv *plocate*.rs layer2_plocate/ 2>/dev/null
mv search_with_parquet.rs layer2_plocate/ 2>/dev/null
mv collect_all_to_parquet.rs layer2_plocate/ 2>/dev/null
echo "  ✓ Plocate tools"

echo ""
echo "Layer 3: GitHub Search"
mv github_repo_finder.rs layer3_github/ 2>/dev/null
mv add_*.rs layer3_github/ 2>/dev/null
echo "  ✓ GitHub tools"

echo ""
echo "Layer 4: Git Packs (TODO)"
echo "  ⏳ Git pack tools to be created"

echo ""
echo "Layer 5: Analysis & Lattice"
mv extract_*.rs rank_*.rs layer5_analysis/ 2>/dev/null
mv pnm_*.rs *lattice*.rs layer5_analysis/ 2>/dev/null
mv construct_orbits.rs deduplicate_rust.rs layer5_analysis/ 2>/dev/null
echo "  ✓ Analysis tools"

echo ""
echo "Shared: Core Systems"
mv *system*.rs *theory*.rs layer5_analysis/ 2>/dev/null
mv deep_q_predictor.rs umberto_eco_scholars.rs layer5_analysis/ 2>/dev/null
mv kurts_library.rs athena_system.rs layer5_analysis/ 2>/dev/null
echo "  ✓ Core systems"

echo ""
echo "✅ Organization complete!"
echo ""
echo "Structure:"
echo "  layer1_terms/      - Keywords, terms, Umberto cards"
echo "  layer2_plocate/    - Plocate search → parquet"
echo "  layer3_github/     - GitHub search & cloning"
echo "  layer4_gitpacks/   - Git pack analysis (TODO)"
echo "  layer5_analysis/   - P×N×M lattice, analysis, systems"
echo "  shared/            - Shared utilities"
