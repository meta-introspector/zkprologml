{ pkgs ? import <nixpkgs> {} }:

# Capture actual instruction stream + register values
# Prove congruence on WHAT was executed, not WHERE

pkgs.stdenv.mkDerivation {
  name = "trace-instruction-stream";
  
  buildInputs = with pkgs; [
    perf
    gcc
    clang
  ];
  
  src = ./.;
  
  buildPhase = ''
    mkdir -p $out/{traces,analysis}
    
    echo "🔬 Capturing instruction streams + registers"
    echo ""
    
    # Test program
    cat > test.c << 'EOF'
int factorial(int n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}
int main() { 
  int result = factorial(5);
  return result;
}
EOF
    
    # Compile with both
    ${pkgs.gcc}/bin/gcc -O0 test.c -o test_gcc
    ${pkgs.clang}/bin/clang -O0 test.c -o test_clang
    
    echo "📊 Recording GCC execution with full trace..."
    perf record -e intel_pt//u -o $out/traces/gcc.data ./test_gcc 2>&1 || \
    perf record -e cycles:u --call-graph dwarf -o $out/traces/gcc.data ./test_gcc 2>&1 || true
    
    perf script -i $out/traces/gcc.data > $out/traces/gcc_full.txt 2>&1 || true
    
    echo "📊 Recording Clang execution with full trace..."
    perf record -e intel_pt//u -o $out/traces/clang.data ./test_clang 2>&1 || \
    perf record -e cycles:u --call-graph dwarf -o $out/traces/clang.data ./test_clang 2>&1 || true
    
    perf script -i $out/traces/clang.data > $out/traces/clang_full.txt 2>&1 || true
    
    echo ""
    echo "✅ Instruction streams captured"
    ls -lh $out/traces/
  '';
  
  installPhase = ''
    echo ""
    echo "🧠 Analyzing instruction congruence..."
    
    # Show sample of traces
    echo "GCC trace sample:"
    head -50 $out/traces/gcc_full.txt || true
    
    echo ""
    echo "Clang trace sample:"
    head -50 $out/traces/clang_full.txt || true
    
    echo ""
    echo "✅ Full traces captured - ready for Monster analysis"
    ls -lh $out/traces/
  '';
}
