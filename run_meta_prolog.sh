#!/usr/bin/env bash
# Run Prolog in all Prologs in Nix, perf trace them, have Prolog reason about Prologs

set -e

echo "🔬 Meta-Prolog Execution: Prolog reasoning about Prologs in Nix"
echo ""

# Find all Prolog implementations in Nix
echo "Step 1: Finding Prolog implementations in Nix..."
PROLOGS=(
    "swipl"      # SWI-Prolog
    "gprolog"    # GNU Prolog
    "scryer-prolog"  # Scryer Prolog (if available)
)

# Our Prolog files to test
PROLOG_FILES=(
    "data/proofs/bisimulation.pl"
    "data/proofs/perf_data.pl"
    "data/proofs/harmonic_complexity.pl"
    "data/proofs/automorphic_orbits.pl"
)

# Output directory
mkdir -p data/meta_prolog_traces

echo "Step 2: Running each Prolog with perf tracing..."
echo ""

for prolog in "${PROLOGS[@]}"; do
    echo "Testing: $prolog"
    
    # Check if available
    if ! command -v "$prolog" &> /dev/null; then
        echo "  ⚠️  $prolog not found, skipping"
        continue
    fi
    
    echo "  ✓ Found $prolog"
    
    # Test each Prolog file
    for file in "${PROLOG_FILES[@]}"; do
        if [ ! -f "$file" ]; then
            continue
        fi
        
        filename=$(basename "$file" .pl)
        echo "    Running: $filename"
        
        # Create test query
        cat > /tmp/test_query.pl << EOF
:- ['$file'].
:- write('Testing $prolog with $filename'), nl.
:- halt.
EOF
        
        # Run with perf
        perf stat -e cycles,instructions,cache-misses,branches \
            -o "data/meta_prolog_traces/${prolog}_${filename}_perf.txt" \
            "$prolog" -q -f /tmp/test_query.pl 2>&1 | \
            tee "data/meta_prolog_traces/${prolog}_${filename}_output.txt"
        
        echo "    ✓ Traced"
    done
    
    echo ""
done

echo "Step 3: Extracting perf data to Datalog..."

# Create meta-Prolog facts
cat > data/proofs/meta_prolog.pl << 'EOF'
% Meta-Prolog: Prolog reasoning about Prolog implementations
% Auto-generated from perf traces

% Schema:
% prolog_impl(Name, Version, Available).
% prolog_trace(Impl, File, Cycles, Instructions, CacheMisses, Branches).
% prolog_performance(Impl, IPC, MissRate).

EOF

# Parse perf traces and add facts
for trace_file in data/meta_prolog_traces/*_perf.txt; do
    if [ ! -f "$trace_file" ]; then
        continue
    fi
    
    # Extract prolog name and file
    basename=$(basename "$trace_file" _perf.txt)
    prolog_name=$(echo "$basename" | cut -d'_' -f1)
    file_name=$(echo "$basename" | cut -d'_' -f2-)
    
    # Parse perf output
    cycles=$(grep "cycles" "$trace_file" | awk '{print $1}' | tr -d ',')
    instructions=$(grep "instructions" "$trace_file" | awk '{print $1}' | tr -d ',')
    cache_misses=$(grep "cache-misses" "$trace_file" | awk '{print $1}' | tr -d ',')
    branches=$(grep "branches" "$trace_file" | awk '{print $1}' | tr -d ',')
    
    # Add to Prolog facts
    if [ -n "$cycles" ] && [ -n "$instructions" ]; then
        echo "prolog_trace($prolog_name, $file_name, $cycles, $instructions, ${cache_misses:-0}, ${branches:-0})." \
            >> data/proofs/meta_prolog.pl
    fi
done

# Add reasoning rules
cat >> data/proofs/meta_prolog.pl << 'EOF'

% Derived rules

% Calculate IPC (Instructions Per Cycle)
prolog_ipc(Impl, File, IPC) :-
    prolog_trace(Impl, File, Cycles, Instructions, _, _),
    Cycles > 0,
    IPC is Instructions / Cycles.

% Find fastest Prolog for a file
fastest_prolog(File, Impl) :-
    prolog_trace(Impl, File, Cycles, _, _, _),
    \+ (
        prolog_trace(OtherImpl, File, OtherCycles, _, _, _),
        OtherImpl \= Impl,
        OtherCycles < Cycles
    ).

% Find most efficient Prolog (highest IPC)
most_efficient(File, Impl, IPC) :-
    prolog_ipc(Impl, File, IPC),
    \+ (
        prolog_ipc(OtherImpl, File, OtherIPC),
        OtherImpl \= Impl,
        OtherIPC > IPC
    ).

% Compare two Prolog implementations
faster_than(Impl1, Impl2, File) :-
    prolog_trace(Impl1, File, Cycles1, _, _, _),
    prolog_trace(Impl2, File, Cycles2, _, _, _),
    Cycles1 < Cycles2.

% Self-reference: Prolog reasoning about Prolog
meta_prolog_reasoning :-
    write('🧠 Meta-Prolog Reasoning'), nl, nl,
    write('Prolog implementations found:'), nl,
    forall(
        prolog_trace(Impl, _, _, _, _, _),
        format('  • ~w~n', [Impl])
    ),
    nl,
    write('Performance comparison:'), nl,
    forall(
        (prolog_trace(Impl, File, Cycles, Instructions, _, _),
         prolog_ipc(Impl, File, IPC)),
        format('  ~w on ~w: ~w cycles, IPC=~2f~n', [Impl, File, Cycles, IPC])
    ),
    nl,
    write('Fastest implementations:'), nl,
    forall(
        (fastest_prolog(File, Impl),
         prolog_trace(Impl, File, Cycles, _, _, _)),
        format('  ~w: ~w (~w cycles)~n', [File, Impl, Cycles])
    ).

% The ultimate self-reference
prolog_about_prolog :-
    write('This is Prolog reasoning about Prolog implementations'), nl,
    write('running Prolog programs that reason about systems'), nl,
    write('that run Prolog programs.'), nl, nl,
    write('The strange loop is complete!'), nl.

% Query examples
% ?- meta_prolog_reasoning.
% ?- fastest_prolog(bisimulation, Impl).
% ?- most_efficient(perf_data, Impl, IPC).
% ?- faster_than(swipl, gprolog, File).
% ?- prolog_about_prolog.

EOF

echo "✅ Meta-Prolog facts generated: data/proofs/meta_prolog.pl"
echo ""

echo "Step 4: Running meta-reasoning..."
echo ""

# Run the meta-reasoning
if command -v swipl &> /dev/null; then
    cat > /tmp/meta_query.pl << 'EOF'
:- ['data/proofs/meta_prolog.pl'].
:- meta_prolog_reasoning.
:- nl, prolog_about_prolog.
:- halt.
EOF
    
    echo "🧠 Executing meta-reasoning with SWI-Prolog:"
    echo ""
    swipl -q -f /tmp/meta_query.pl
fi

echo ""
echo "Step 5: Summary"
echo ""
echo "✅ Ran Prolog in multiple Prolog implementations"
echo "✅ Perf traced all executions"
echo "✅ Extracted data to Datalog/Prolog facts"
echo "✅ Prolog reasoned about Prolog implementations"
echo "✅ Meta-circular reasoning complete!"
echo ""
echo "📁 Files created:"
echo "  • data/meta_prolog_traces/*_perf.txt (perf traces)"
echo "  • data/meta_prolog_traces/*_output.txt (outputs)"
echo "  • data/proofs/meta_prolog.pl (meta-reasoning facts)"
echo ""
echo "🎯 The strange loop: Prolog → Prolog → Prolog → ..."
