{ pkgs ? import <nixpkgs> {} }:

pkgs.runCommand "test-microphone" {
  buildInputs = [ pkgs.alsa-utils ];
} ''
  mkdir -p $out
  
  echo "Testing microphone..."
  
  # List audio devices
  arecord -l > $out/devices.txt 2>&1 || echo "No devices found" > $out/devices.txt
  
  # Record 5 seconds
  arecord -d 5 -f cd $out/test.wav 2>&1 || echo "Recording failed" > $out/error.txt
  
  # Check if file was created
  if [ -f $out/test.wav ]; then
    ls -lh $out/test.wav > $out/recording_info.txt
    echo "Recording successful" > $out/status.txt
  else
    echo "Recording failed" > $out/status.txt
  fi
''
