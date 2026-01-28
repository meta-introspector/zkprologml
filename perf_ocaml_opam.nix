{ pkgs ? import <nixpkgs> {} }:

# Perf record OCaml compilation and opam builds
# Label bytes with Monster primes via goblin ELF analysis

pkgs.stdenv.mkDerivation {
  name = "perf-ocaml-opam";
  
  buildInputs = with pkgs; [
    linuxPackages.perf
    ocaml
    opam
    swiProlog
  ];
  
  src = ./.;
  
  buildPhase = ''
    mkdir -p $out/traces
    
    echo "🔬 Perf recording OCaml compilation..."
    
    # Find OCaml source to compile
    OCAML_FILE=$(find ${./data/proofs} -name "*.ml" -type f | head -1 || echo "")
    
    if [ -n "$OCAML_FILE" ]; then
      echo "  Compiling: $OCAML_FILE"
      perf record -e cycles,instructions,cache-misses \
        -o $out/traces/ocaml_compile.data \
        ${pkgs.ocaml}/bin/ocamlc -c $OCAML_FILE 2>&1 || true
      
      perf script -i $out/traces/ocaml_compile.data > $out/traces/ocaml_compile.txt || true
    fi
    
    echo ""
    echo "🐪 Perf recording opam operations..."
    
    # Record opam list (slow operation)
    perf record -e cycles,instructions,cache-misses \
      -o $out/traces/opam_list.data \
      ${pkgs.opam}/bin/opam list 2>&1 || true
    
    perf script -i $out/traces/opam_list.data > $out/traces/opam_list.txt || true
    
    echo ""
    echo "✅ Traces saved to $out/traces/"
    ls -lh $out/traces/
  '';
  
  installPhase = ''
    echo "📊 Analyzing traces with Rust..."
    
    # Build and run the analyzer
    cd ${./.}
    cargo build --release --bin analyze_ocaml_traces 2>&1 || echo "Build skipped"
    
    if [ -f target/release/analyze_ocaml_traces ]; then
      ./target/release/analyze_ocaml_traces $out/traces
    fi
    
    echo ""
    echo "🧠 Ingesting with Prolog..."
    cd ${./data/proofs}
    ${pkgs.swiProlog}/bin/swipl -g main -t halt ingest_ocaml_perf.pl || true
  '';
}
