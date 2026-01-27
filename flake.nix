{
  description = "zkPrologML - Universal Prolog via Prime Complexity ABI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # All Prolog implementations
        prologImpls = {
          scryer = pkgs.scryer-prolog;
          swi = pkgs.swiProlog;
          gnu = pkgs.gprolog;
          trealla = pkgs.trealla;
        };
        
        # Fork, patch, port pipeline
        zkprologml = import ./prolog_fork_nix.nix { inherit pkgs; };
        
      in {
        packages = {
          default = zkprologml;
          
          # Individual Prolog implementations
          scryer = prologImpls.scryer;
          swi = prologImpls.swi;
          gnu = prologImpls.gnu;
          trealla = prologImpls.trealla;
        };
        
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # All Prolog implementations
            scryer-prolog
            swiProlog
            gprolog
            trealla
            
            # Rust toolchain
            rustc
            cargo
            
            # Build tools
            git
            gnumake
          ];
          
          shellHook = ''
            echo "🍄 zkPrologML Development Environment"
            echo "Available Prolog implementations:"
            echo "  - Scryer: scryer-prolog"
            echo "  - SWI: swipl"
            echo "  - GNU: gprolog"
            echo "  - Trealla: trealla"
            echo ""
            echo "Run: ./eval_all_prolog.sh"
          '';
        };
        
        apps.default = {
          type = "app";
          program = "${zkprologml}/bin/universal_call_scryer";
        };
      }
    );
}
