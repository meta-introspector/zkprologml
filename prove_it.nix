{ pkgs ? import <nixpkgs> {} }:

# PROVE IT: Compiler congruence via Monster primes

let
  prove_it = pkgs.rustPlatform.buildRustPackage {
    pname = "prove_it";
    version = "0.1.0";
    src = ./.;
    cargoLock.lockFile = ./Cargo.lock;
  };
in

pkgs.stdenv.mkDerivation {
  name = "prove-compiler-congruence";
  
  buildInputs = with pkgs; [ gcc prove_it ];
  
  src = ./.;
  
  buildPhase = ''
    mkdir -p $out
    
    echo "🔬 PROVING COMPILER CONGRUENCE"
    echo ""
    
    # Test program
    cat > test.c << 'EOF'
int factorial(int n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}
int main() { return factorial(5); }
EOF
    
    # Compile with GCC
    ${pkgs.gcc}/bin/gcc -O0 test.c -o test_gcc
    
    echo "✅ Compiled test_gcc"
    ls -lh test_gcc
    
    # Run proof
    ${prove_it}/bin/prove_it
  '';
  
  installPhase = ''
    echo "✅ PROOF COMPLETE"
  '';
}
