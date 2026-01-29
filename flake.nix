{
  description = "zkPrologML with eRDFa WASM integration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    namespace.url = "github:Escaped-RDFa/namespace";
  };

  outputs = { self, nixpkgs, namespace }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        # Use eRDFa WASM from namespace flake
        erdfa-wasm = namespace.packages.${system}.default or namespace.packages.${system}.erdfa-wasm;
        default = self.packages.${system}.erdfa-wasm;
      };
      
      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ namespace.devShells.${system}.default or {} ];
        
        shellHook = ''
          echo "🚀 zkPrologML + eRDFa"
          echo "Build WASM: nix build .#erdfa-wasm"
          echo "Deploy: cd data/proofs/deploy && git push space main"
        '';
      };
    };
}
