# Layer 57 - Monster Prime 47 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-57-prime-47";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_57.rs -o layer_57
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_57 $out/bin/
  '';
  
  meta = {
    description = "Layer 57 computation (Monster prime 47, genus 0)";
  };
}
