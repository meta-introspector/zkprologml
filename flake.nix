{
  description = "Test compiler equivalence at each prime complexity level";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "compiler-equivalence-tests";
        
        buildInputs = with pkgs; [
          gcc
          clang
          tinycc
          swi-prolog
        ];
        
        src = ./.;
        
        buildPhase = ''
          mkdir -p $out/tests
          cd $out/tests
          
          echo "🔬 COMPILER EQUIVALENCE TESTS"
          echo "═══════════════════════════════════════════════════════════"
          echo ""
          
          # Copy test script
          cp ${./data/proofs/test_compiler_equivalence.pl} test_compiler_equivalence.pl
          
          # Update compiler paths in Prolog
          cat > compiler_paths.pl << 'EOF'
compiler_cmd(gcc, '${pkgs.gcc}/bin/gcc').
compiler_cmd(clang, '${pkgs.clang}/bin/clang').
compiler_cmd(tcc, '${pkgs.tinycc}/bin/tcc').
EOF
          
          echo "✅ Compilers available:"
          echo "  GCC: ${pkgs.gcc}/bin/gcc"
          echo "  Clang: ${pkgs.clang}/bin/clang"
          echo "  TCC: ${pkgs.tinycc}/bin/tcc"
          echo ""
          
          # Run tests
          ${pkgs.swi-prolog}/bin/swipl -g main -t halt test_compiler_equivalence.pl 2>&1 | tee results.txt
        '';
        
        installPhase = ''
          echo ""
          echo "✅ Tests complete"
          ls -lh $out/tests/
        '';
      };
      
      # Development shell
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          gcc
          clang
          tinycc
          swi-prolog
          perf
        ];
        
        shellHook = ''
          echo "🔬 Compiler Equivalence Test Environment"
          echo ""
          echo "Available compilers:"
          echo "  gcc: $(which gcc)"
          echo "  clang: $(which clang)"
          echo "  tcc: $(which tcc)"
          echo ""
          echo "Run: cd data/proofs && swipl -g main -t halt test_compiler_equivalence.pl"
        '';
      };
    };
}
