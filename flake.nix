{
  description = "zkPrologML - Universal Prolog Meta-Language";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06";
  };

  outputs = { self, nixpkgs, gemini-cli }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "zkprologml";
        
        buildInputs = with pkgs; [
          # Core
          swipl
          rustc
          cargo
          
          # Proof systems
          lean4
          coq
          
          # Audio
          lilypond
          alsa-utils
          
          # Data
          python3
          python3Packages.pandas
          python3Packages.pyarrow
          
          # LLM interface
          gemini-cli.packages.${system}.default
          
          # Utils
          qrencode
          git
        ];
        
        shellHook = ''
          echo ""
          echo "♾️  zkPrologML Environment"
          echo "═══════════════════════════════════════════════════════════"
          echo ""
          echo "Run: ./boot.sh to bootstrap"
          echo ""
          
          # Load Gödel lattice
          export ZKPROLOG_LATTICE="$PWD/data/proofs/generated/godel_lattice.parquet"
          
          # Gemini CLI available
          export GEMINI_CLI="$(which gemini)"
          
          echo "Gödel lattice: $ZKPROLOG_LATTICE"
          echo "Gemini CLI: $GEMINI_CLI"
          echo ""
        '';
      };
      
      packages.${system}.default = pkgs.writeShellScriptBin "zkprologml" ''
        ${pkgs.swipl}/bin/swipl -g boot -t halt ${./boot.pl}
      '';
    };
}
