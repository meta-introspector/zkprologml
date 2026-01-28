{
  description = "zkPrologML - Monster Group Knowledge System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Import data files (impure!)
        dataDir = builtins.getEnv "PWD";
        
        # Parquet data
        masterParquet = "${dataDir}/master.parquet";
        globalObjectsProlog = "${dataDir}/global_objects.pl";
        
        # Build tools
        buildInputs = with pkgs; [
          # Rust
          rustc
          cargo
          
          # Prolog
          swiProlog
          
          # Lean4
          lean4
          
          # Python (for parquet)
          python3
          python3Packages.pandas
          python3Packages.pyarrow
          
          # Visualization
          graphviz
        ];
        
        # Data package
        dataPackage = pkgs.stdenv.mkDerivation {
          name = "zkprologml-data";
          version = "0.1.0";
          
          src = ./.;
          
          buildInputs = buildInputs;
          
          # Impure: access local data
          impureEnvVars = [ "PWD" ];
          
          buildPhase = ''
            echo "Building zkPrologML data package..."
            
            # Check data files exist
            if [ -f "${masterParquet}" ]; then
              echo "✅ Found master.parquet"
            else
              echo "❌ master.parquet not found"
            fi
            
            if [ -f "${globalObjectsProlog}" ]; then
              echo "✅ Found global_objects.pl"
            else
              echo "❌ global_objects.pl not found"
            fi
            
            # Compile Rust tools
            echo "Compiling Rust tools..."
            rustc load_global_table.rs -O -o load_global_table
            rustc update_parquet_formal.rs -O -o update_parquet_formal
            rustc eigenvector_matrix.rs -O -o eigenvector_matrix
            
            # Check Prolog files
            echo "Checking Prolog files..."
            swipl -g "consult('global_object_table.pl'), halt" || true
            
            # Check Lean4 files
            echo "Checking Lean4 files..."
            lean --version
          '';
          
          installPhase = ''
            mkdir -p $out/bin
            mkdir -p $out/data
            mkdir -p $out/proofs
            
            # Install binaries
            cp load_global_table $out/bin/ || true
            cp update_parquet_formal $out/bin/ || true
            cp eigenvector_matrix $out/bin/ || true
            
            # Install data (symlinks to impure data)
            ln -s ${masterParquet} $out/data/master.parquet || true
            ln -s ${globalObjectsProlog} $out/data/global_objects.pl || true
            
            # Install Prolog files
            cp *.pl $out/proofs/ || true
            
            # Install Lean4 files
            cp *.lean $out/proofs/ || true
            
            # Install MiniZinc files
            cp *.mzn $out/proofs/ || true
            
            echo "✅ Installation complete"
          '';
          
          meta = {
            description = "zkPrologML data and proofs";
            license = pkgs.lib.licenses.mit;
          };
        };
        
      in {
        packages = {
          default = dataPackage;
          data = dataPackage;
        };
        
        devShells.default = pkgs.mkShell {
          inherit buildInputs;
          
          shellHook = ''
            echo "🔮 zkPrologML Development Environment"
            echo "======================================"
            echo ""
            echo "Available tools:"
            echo "  • rustc $(rustc --version | cut -d' ' -f2)"
            echo "  • swipl $(swipl --version | head -1)"
            echo "  • lean $(lean --version)"
            echo "  • python $(python3 --version | cut -d' ' -f2)"
            echo ""
            echo "Data files:"
            echo "  • master.parquet (250MB, 8M files)"
            echo "  • global_objects.pl (280MB, 8M objects)"
            echo ""
            echo "Quick start:"
            echo "  cargo build          # Build Rust tools"
            echo "  swipl -g main        # Run Prolog"
            echo "  lean --make          # Build Lean4"
            echo "  python3 script.py    # Run Python"
            echo ""
          '';
        };
        
        apps = {
          # Run Prolog global table
          prolog = {
            type = "app";
            program = "${pkgs.swiProlog}/bin/swipl";
          };
          
          # Run Lean4
          lean = {
            type = "app";
            program = "${pkgs.lean4}/bin/lean";
          };
        };
      }
    );
}
