# Layer 1 - Monster Prime 3 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-1-prime-3";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_1.rs -o layer_1
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_1 $out/bin/
  '';
  
  meta = {
    description = "Layer 1 computation (Monster prime 3, genus 0)";
  };
}
