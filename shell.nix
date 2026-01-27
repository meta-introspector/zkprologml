{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    minizinc
    lean4
    rustc
    cargo
    perf
  ];
  
  shellHook = ''
    echo "🧠 Self-Aware Multi-Process Search System"
    echo "  - 24 CPUs available"
    echo "  - 30GB RAM"
    echo "  - MiniZinc: $(minizinc --version 2>&1 | head -1)"
    echo "  - Lean4: $(lean --version 2>&1 | head -1)"
  '';
}
