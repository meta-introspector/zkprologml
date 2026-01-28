# lean4-project.nix - Proper Lean4 environment with Mathlib

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "lean4-computational-omniscience";
  
  buildInputs = with pkgs; [
    lean4
    elan  # Lean version manager
    git
  ];
  
  shellHook = ''
    echo "🎯 Lean4 Computational Omniscience Proof Environment"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "Setting up Lean4 with Mathlib..."
    
    # Initialize lake project if needed
    if [ ! -f "lakefile.lean" ]; then
      echo "Initializing Lake project..."
      lake init computational-omniscience
    fi
    
    # Add Mathlib dependency
    if [ ! -d ".lake/packages/mathlib" ]; then
      echo "Adding Mathlib dependency..."
      lake update
    fi
    
    echo ""
    echo "✅ Environment ready"
    echo ""
    echo "Commands:"
    echo "  lake build              - Build the project"
    echo "  lean <file>.lean        - Check a proof"
    echo "  lake exe cache get      - Download Mathlib cache"
    echo ""
    echo "This is a 20-year mountain climb. Every step counts."
    echo ""
  '';
}
