{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "optimal-build-plan";
  
  buildInputs = [ pkgs.minizinc pkgs.coreutils ];
  
  src = ./.;
  
  buildPhase = ''
    # Detect resources
    CPUS=$(nproc)
    MEMORY=$(free -g | awk '/^Mem:/ {print $2}')
    
    echo "🔍 System Resources:"
    echo "  CPUs: $CPUS"
    echo "  Memory: ''${MEMORY}GB"
    echo ""
    
    # Generate data file
    cat > build_plan.dzn << EOF
NUM_CPUS = $CPUS;
MEMORY_GB = $MEMORY;
EOF
    
    echo "🧮 Solving with MiniZinc..."
    echo ""
    
    ${pkgs.minizinc}/bin/minizinc \
      --solver gecode \
      shared/nix/optimal_build_plan.mzn \
      build_plan.dzn
  '';
  
  installPhase = ''
    mkdir -p $out
    
    CPUS=$(nproc)
    MEMORY=$(free -g | awk '/^Mem:/ {print $2}')
    
    cat > build_plan.dzn << EOF
NUM_CPUS = $CPUS;
MEMORY_GB = $MEMORY;
EOF
    
    ${pkgs.minizinc}/bin/minizinc \
      --solver gecode \
      shared/nix/optimal_build_plan.mzn \
      build_plan.dzn > $out/OPTIMAL_BUILD_PLAN.txt
    
    echo "✅ Saved to $out/OPTIMAL_BUILD_PLAN.txt"
  '';
}
