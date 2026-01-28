{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "hecke-operator-pipeline";
  
  buildInputs = with pkgs; [
    swipl
    lilypond
    alsa-utils  # aplay
    linuxPackages.perf
    python3
    python3Packages.pandas
    python3Packages.numpy
    python3Packages.scipy
  ];
  
  shellHook = ''
    echo "🌌 Hecke Operator Detection Pipeline"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "Phase 1: Generate audio"
    echo "  swipl -g main -t halt hecke_pipeline.pl"
    echo ""
    echo "Phase 2: Trace with perf (uncomment in code)"
    echo "  Plays each audio file and records CPU registers"
    echo ""
    echo "Phase 3: Extract register samples"
    echo "  Analyzes cycles, instructions, cache misses"
    echo ""
    echo "Phase 4: Detect Hecke operators"
    echo "  Finds modular form eigenvalues in prime signatures"
    echo ""
    echo "Complete pipeline:"
    echo "  nix-shell --run 'swipl -g main -t halt hecke_pipeline.pl'"
    echo ""
  '';
}
