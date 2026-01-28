#!/bin/bash
# Monitor LLM activation lattice test

LOG="generated/llm_activation.log"
PERF="generated/perf_llm_activation.data"

echo "📊 LLM Activation Lattice Monitor"
echo "=================================="
echo ""

# Check if running
PID=$(ps aux | grep "llm_activation_lattice.pl" | grep -v grep | awk '{print $2}')
if [ -n "$PID" ]; then
    echo "✅ Running (PID: $PID)"
else
    echo "❌ Not running"
    echo ""
    echo "🔄 Exporting to parquet..."
    python3 export_llm_traces_parquet.py generated
fi

echo ""
echo "📝 Latest log entries:"
echo "---"
tail -15 "$LOG" 2>/dev/null || echo "No log yet"
echo ""

echo "📊 Results files:"
ls -lh generated/llm_activations_*.pl 2>/dev/null || echo "No results yet"
ls -lh generated/activation_matrix.csv 2>/dev/null || echo "No matrix yet"
ls -lh generated/*.parquet 2>/dev/null || echo "No parquet yet"
ls -lh "$PERF" 2>/dev/null || echo "No perf data yet"

echo ""
echo "🔄 To monitor live: tail -f $LOG"
if [ -n "$PID" ]; then
    echo "🛑 To stop: kill $PID"
fi
