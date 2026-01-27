#!/bin/bash
# Evaluate all Prolog files with oracle agreement protocol

echo "🔍 EVALUATING ALL PROLOG FILES"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Key files from our work
FILES=(
    "data/proofs/horizontal_meme_transfer.pl"
    "data/proofs/universal_port.pl"
    "data/proofs/monster_lattice_features.pl"
    "data/proofs/monster_port.pl"
    "data/proofs/eternal_proof_loop.pl"
    "data/proofs/complexity_growth_proof.pl"
    "data/proofs/24h_resource_plan.pl"
    "data/proofs/solana_predictor.pl"
    "data/proofs/pump_token_tracker.pl"
    "data/proofs/multichain_anon_sampler.pl"
    "data/proofs/zk_witness_system.pl"
    "data/proofs/self_replicating_seed.pl"
    "data/proofs/zkprologml_metacoq_equiv.pl"
    "data/proofs/real_measurements.pl"
    "data/proofs/safe_oracle_injection.pl"
)

RESULTS_FILE="prolog_eval_results.txt"
> "$RESULTS_FILE"

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$RESULTS_FILE"
        echo "📄 $file" | tee -a "$RESULTS_FILE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$RESULTS_FILE"
        
        # Check for constants
        echo "" | tee -a "$RESULTS_FILE"
        echo "🔍 Checking for constants..." | tee -a "$RESULTS_FILE"
        CONSTANTS=$(grep -E "^[a-z_]+\([0-9]+\)" "$file" | head -5)
        if [ -n "$CONSTANTS" ]; then
            echo "⚠️  Found constants:" | tee -a "$RESULTS_FILE"
            echo "$CONSTANTS" | tee -a "$RESULTS_FILE"
        else
            echo "✅ No obvious constants" | tee -a "$RESULTS_FILE"
        fi
        
        # Check for oracle calls
        echo "" | tee -a "$RESULTS_FILE"
        echo "🔍 Checking for oracle integration..." | tee -a "$RESULTS_FILE"
        if grep -q "oracle" "$file"; then
            echo "✅ Has oracle integration" | tee -a "$RESULTS_FILE"
        else
            echo "❌ Missing oracle integration" | tee -a "$RESULTS_FILE"
        fi
        
        # Check for measurements
        echo "" | tee -a "$RESULTS_FILE"
        echo "🔍 Checking for measurements..." | tee -a "$RESULTS_FILE"
        if grep -q "measure\|shell\|process_create" "$file"; then
            echo "✅ Has measurement calls" | tee -a "$RESULTS_FILE"
        else
            echo "❌ Missing measurement calls" | tee -a "$RESULTS_FILE"
        fi
        
        # Try to load
        echo "" | tee -a "$RESULTS_FILE"
        echo "🔍 Testing load..." | tee -a "$RESULTS_FILE"
        cat > /tmp/test_load.pl << EOF
:- catch(consult('$file'), E, (write('ERROR: '), write(E), nl, halt(1))).
:- write('✅ Loaded successfully'), nl.
:- halt(0).
EOF
        
        if timeout 5 swipl -q -f /tmp/test_load.pl 2>&1 | tee -a "$RESULTS_FILE"; then
            echo "✅ Load successful" | tee -a "$RESULTS_FILE"
        else
            echo "❌ Load failed" | tee -a "$RESULTS_FILE"
        fi
        
        echo "" | tee -a "$RESULTS_FILE"
    else
        echo "⚠️  File not found: $file" | tee -a "$RESULTS_FILE"
        echo "" | tee -a "$RESULTS_FILE"
    fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$RESULTS_FILE"
echo "📊 SUMMARY" | tee -a "$RESULTS_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$RESULTS_FILE"
echo "" | tee -a "$RESULTS_FILE"

TOTAL=${#FILES[@]}
WITH_ORACLE=$(grep -l "oracle" "${FILES[@]}" 2>/dev/null | wc -l)
WITH_MEASURE=$(grep -l "measure\|shell\|process_create" "${FILES[@]}" 2>/dev/null | wc -l)

echo "Total files: $TOTAL" | tee -a "$RESULTS_FILE"
echo "With oracle: $WITH_ORACLE" | tee -a "$RESULTS_FILE"
echo "With measurements: $WITH_MEASURE" | tee -a "$RESULTS_FILE"
echo "" | tee -a "$RESULTS_FILE"

echo "Results saved to: $RESULTS_FILE"
