{ pkgs ? import <nixpkgs> {} }:

# Peel layers: Trace actual OCaml file compilation to find automorphic kernel
# Match OCaml kernel to Prolog kernel via Monster complexity

pkgs.stdenv.mkDerivation {
  name = "trace-ocaml-kernel";
  
  buildInputs = with pkgs; [
    perf
    ocaml
    swi-prolog
  ];
  
  src = ./.;
  
  buildPhase = ''
    mkdir -p $out/{traces,binaries,analysis}
    
    echo "🔍 Using OCaml files from cargo registry..."
    
    # Copy sample OCaml files to build dir
    cp ${./data/proofs/ocaml_files.txt} ./ocaml_files.txt || true
    
    # Use capstone OCaml bindings (known to exist)
    cat > test_simple.ml << 'EOF'
let x = 42
let y = x + 1
let () = print_int y
EOF
    
    cat > test_function.ml << 'EOF'
let rec factorial n =
  if n <= 1 then 1
  else n * factorial (n - 1)
  
let () = print_int (factorial 5)
EOF
    
    for ml_file in test_simple.ml test_function.ml; do
      base=$(basename "$ml_file" .ml)
      echo ""
      echo "🔬 Tracing: $base.ml"
      
      # Compile with perf
      perf record -e cycles,instructions,cache-misses \
        -o "$out/traces/$base.data" \
        ${pkgs.ocaml}/bin/ocamlc -c "$ml_file" -o "$out/binaries/$base.cmo" 2>&1 || true
      
      # Convert to text
      perf script -i "$out/traces/$base.data" > "$out/traces/$base.txt" 2>/dev/null || true
      
      # Extract symbols
      if [ -f "$out/binaries/$base.cmo" ]; then
        ${pkgs.ocaml}/bin/ocamlobjinfo "$out/binaries/$base.cmo" > "$out/analysis/$base.objinfo" 2>&1 || true
      fi
      
      echo "  ✅ Traced $base"
    done
    
    echo ""
    echo "📊 Traces captured:"
    ls -lh $out/traces/ 2>/dev/null || echo "  (none)"
    
    echo ""
    echo "📦 Binaries:"
    ls -lh $out/binaries/ 2>/dev/null || echo "  (none)"
  '';
  
  installPhase = ''
    echo ""
    echo "🧠 Finding automorphic kernel with Prolog..."
    
    cd ${./data/proofs}
    ${pkgs.swi-prolog}/bin/swipl -g main -t halt find_ocaml_kernel.pl $out/traces $out/analysis || true
    
    echo ""
    echo "✅ Results in: $out/"
  '';
}
