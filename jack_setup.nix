{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.jack2
    pkgs.qjackctl
    pkgs.alsa-utils
  ];
  
  shellHook = ''
    echo "Setting up JACK headless..."
    
    # Start JACK daemon
    jackd -d alsa -d hw:0 -r 44100 -p 1024 -n 2 &
    JACK_PID=$!
    
    echo "JACK started (PID: $JACK_PID)"
    sleep 2
    
    # Check JACK status
    jack_lsp
    
    echo "JACK is ready!"
    echo "To stop: kill $JACK_PID"
  '';
}
