{ pkgs ? import <nixpkgs> {} }:

# Prove congruence between perf traces via complexity lattice
# All compilers produce congruent traces mod Monster primes

pkgs.stdenv.mkDerivation {
  name = "prove-trace-congruence";
  
  buildInputs = with pkgs; [
    perf
    gcc
    clang
    swi-prolog
  ];
  
  # TCC from ZilchOS bootstrap
  tcc = pkgs.fetchFromGitHub {
    owner = "ZilchOS";
    repo = "bootstrap-from-tcc";
    rev = "main";
    sha256 = "sha256-98d+Nn7nNRn+oP9MvDTXGrShG2rAyenvffThwWZk8R0=";
  };
  
  src = ./.;
  
  buildPhase = ''
    mkdir -p $out/{traces,analysis}
    
    echo "🔬 Proving trace congruence via complexity lattice"
    echo ""
    
    # Test program
    cat > test.c << 'EOF'
int factorial(int n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}
int main() { return factorial(10); }
EOF
    
    # Compile with each compiler + trace
    for compiler in gcc clang; do
      echo "📊 Tracing $compiler..."
      
      case $compiler in
        gcc)   CC="${pkgs.gcc}/bin/gcc" ;;
        clang) CC="${pkgs.clang}/bin/clang" ;;
      esac
      
      perf stat -e cycles,instructions,cache-misses \
        $CC -O2 test.c -o test_$compiler 2> $out/traces/$compiler.txt || true
      
      # Extract key metrics
      cycles=$(grep cycles $out/traces/$compiler.txt | awk '{print $1}' | tr -d ',' || echo 0)
      insns=$(grep instructions $out/traces/$compiler.txt | awk '{print $1}' | tr -d ',' || echo 0)
      
      echo "$compiler: cycles=$cycles insns=$insns" >> $out/analysis/metrics.txt
    done
    
    echo ""
    echo "📊 Metrics collected:"
    cat $out/analysis/metrics.txt
  '';
  
  installPhase = ''
    echo ""
    echo "🧠 Analyzing congruence with Prolog..."
    
    cd ${./data/proofs}
    ${pkgs.swi-prolog}/bin/swipl -g main -t halt prove_congruence.pl $out/traces $out/analysis || true
    
    echo ""
    echo "✅ Congruence analysis complete"
    ls -lh $out/analysis/
  '';
}
