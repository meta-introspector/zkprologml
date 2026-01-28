#!/bin/bash
# Background LLM activation test with perf tracing

cd "$(dirname "$0")"

echo "🚀 Starting LLM activation lattice test in background..."

# Run with perf trace
nohup perf record -e cycles,instructions,cache-misses \
    -o generated/perf_llm_activation.data \
    -- swipl -g main -t halt llm_activation_lattice.pl \
    > generated/llm_activation.log 2>&1 &

PID=$!
echo "🔄 Background PID: $PID"
echo "📝 Log: generated/llm_activation.log"
echo "📊 Perf: generated/perf_llm_activation.data"
echo ""
echo "Monitor with: tail -f generated/llm_activation.log"
echo "Kill with: kill $PID"
