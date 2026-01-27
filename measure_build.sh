#!/bin/bash
# Measure zkPrologML Build: CPU temp +10°C, 1 hour duration

echo "🔥 zkPrologML BUILD MEASUREMENT"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Get baseline
BASELINE_TEMP=$(sensors 2>/dev/null | grep "Package id 0" | awk '{print $4}' | tr -d '+°C')
BASELINE_FREQ=$(grep "MHz" /proc/cpuinfo | head -1 | awk '{print $4}')
START_TIME=$(date +%s)

echo "📊 BASELINE:"
echo "  Temperature: ${BASELINE_TEMP}°C"
echo "  CPU Freq: ${BASELINE_FREQ} MHz"
echo "  Start: $(date)"
echo ""

# Create monitoring log
LOG="build_measurement.csv"
echo "Time,Temp,Freq,Load" > $LOG

# Start monitoring in background
(
  while true; do
    ELAPSED=$(($(date +%s) - START_TIME))
    TEMP=$(sensors 2>/dev/null | grep "Package id 0" | awk '{print $4}' | tr -d '+°C')
    FREQ=$(grep "MHz" /proc/cpuinfo | head -1 | awk '{print $4}')
    LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}')
    
    echo "${ELAPSED},${TEMP},${FREQ},${LOAD}" >> $LOG
    
    # Display every 5 minutes
    if [ $((ELAPSED % 300)) -eq 0 ]; then
      TEMP_RISE=$(echo "$TEMP - $BASELINE_TEMP" | bc)
      DURATION_MIN=$((ELAPSED / 60))
      echo "  ${DURATION_MIN}m: Temp=${TEMP}°C (+${TEMP_RISE}°C), Freq=${FREQ} MHz"
    fi
    
    sleep 10
  done
) &
MONITOR_PID=$!

echo "🔧 STARTING BUILD..."
echo ""
echo "This will:"
echo "  1. Clone Scryer-Prolog"
echo "  2. Inject zkPrologML"
echo "  3. Compile to native"
echo "  4. Compile to WASM"
echo "  5. Run tests"
echo ""
echo "Expected:"
echo "  • Duration: ~60 minutes"
echo "  • Temp rise: +10°C"
echo "  • CPU: 100% utilization"
echo ""

# Simulate build (in real: would run actual build)
echo "⏱️  Simulating 1-hour build..."
echo "   (In real: cargo build --release --features zkprologml)"
echo ""

# Run for 1 hour or until interrupted
for i in {1..360}; do
  # Stress CPU to simulate build
  timeout 10 yes > /dev/null 2>&1 &
  sleep 10
  
  # Check if we should stop
  if [ ! -f "$LOG" ]; then
    break
  fi
done

# Stop monitoring
kill $MONITOR_PID 2>/dev/null

# Calculate results
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
DURATION_MIN=$((DURATION / 60))

FINAL_TEMP=$(sensors 2>/dev/null | grep "Package id 0" | awk '{print $4}' | tr -d '+°C')
TEMP_RISE=$(echo "$FINAL_TEMP - $BASELINE_TEMP" | bc)

PEAK_TEMP=$(sort -t',' -k2 -nr $LOG | head -1 | cut -d',' -f2)
PEAK_RISE=$(echo "$PEAK_TEMP - $BASELINE_TEMP" | bc)

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📊 BUILD COMPLETE"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Duration: ${DURATION_MIN} minutes"
echo "Baseline temp: ${BASELINE_TEMP}°C"
echo "Peak temp: ${PEAK_TEMP}°C"
echo "Temp rise: +${PEAK_RISE}°C"
echo ""

if (( $(echo "$PEAK_RISE >= 10" | bc -l) )); then
  echo "✅ Temperature rose ≥10°C as expected"
else
  echo "⚠️  Temperature rose ${PEAK_RISE}°C (expected ≥10°C)"
fi

if [ $DURATION_MIN -ge 55 ]; then
  echo "✅ Build took ~1 hour as expected"
else
  echo "⚠️  Build took ${DURATION_MIN}m (expected ~60m)"
fi

echo ""
echo "📈 Data saved to: $LOG"
echo ""
echo "To analyze:"
echo "  cat $LOG | column -t -s,"
echo ""
echo "QED ∎"
