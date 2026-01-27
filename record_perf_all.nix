{ pkgs ? import <nixpkgs> {} }:

let
  # Record everything: perf, audio, RF, temp while running Prolog
  recordAll = pkgs.writeShellScript "record-all" ''
    TIMESTAMP=$(date +%s)
    
    echo "🎙️  Recording: perf + audio + RF + temp..."
    
    # Start temperature monitoring
    ${pkgs.lm_sensors}/bin/sensors -u > temp_before_$TIMESTAMP.txt &
    TEMP_PID=$!
    
    # Start audio recording (if available)
    ${pkgs.alsa-utils}/bin/arecord -f cd -d 60 audio_$TIMESTAMP.wav 2>/dev/null &
    AUDIO_PID=$!
    
    # Start RF monitoring (if rtl-sdr available)
    # rtl_power -f 88M:108M:1M -i 1 rf_$TIMESTAMP.csv &
    # RF_PID=$!
    
    # Run Prolog with perf
    ${pkgs.linuxPackages.perf}/bin/perf record \
      -e cycles,instructions,cache-misses,branch-misses,cpu-clock,task-clock \
      -o perf_prolog_$TIMESTAMP.data \
      ${pkgs.swi-prolog}/bin/swipl -g main -t halt ${./data/proofs/infer_rust_producers.pl}
    
    # Stop monitoring
    kill $TEMP_PID 2>/dev/null || true
    kill $AUDIO_PID 2>/dev/null || true
    # kill $RF_PID 2>/dev/null || true
    
    # Record temp after
    ${pkgs.lm_sensors}/bin/sensors -u > temp_after_$TIMESTAMP.txt
    
    # Extract perf data
    ${pkgs.linuxPackages.perf}/bin/perf script -i perf_prolog_$TIMESTAMP.data > perf_prolog_$TIMESTAMP.trace
    
    echo "✅ Recording complete: $TIMESTAMP"
    echo "  perf: perf_prolog_$TIMESTAMP.data"
    echo "  audio: audio_$TIMESTAMP.wav"
    echo "  temp: temp_before/after_$TIMESTAMP.txt"
  '';

in pkgs.stdenv.mkDerivation {
  name = "zkprologml-perf-record";
  src = ./.;
  
  buildInputs = with pkgs; [
    linuxPackages.perf
    swi-prolog
    lm_sensors
    alsa-utils
  ];
  
  buildPhase = ''
    ${recordAll}
  '';
  
  installPhase = ''
    mkdir -p $out/share/zkprologml/recordings
    
    # Copy all recordings
    cp perf_prolog_*.data $out/share/zkprologml/recordings/ || true
    cp perf_prolog_*.trace $out/share/zkprologml/recordings/ || true
    cp audio_*.wav $out/share/zkprologml/recordings/ || true
    cp temp_*.txt $out/share/zkprologml/recordings/ || true
    
    # Summary
    echo "Performance Recording Summary" > $out/share/zkprologml/summary.txt
    echo "Recorded: perf, audio, temperature" >> $out/share/zkprologml/summary.txt
    ls -lh $out/share/zkprologml/recordings/ >> $out/share/zkprologml/summary.txt
  '';
  
  meta = {
    description = "Record perf, audio, RF, and temperature while running Prolog inference";
  };
}
