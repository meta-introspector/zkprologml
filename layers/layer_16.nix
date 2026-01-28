# Layer 16 - Monster Prime 3 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-16-prime-3";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_16.rs -o layer_16
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_16 $out/bin/
  '';
  
  meta = {
    description = "Layer 16 computation (Monster prime 3, genus 0)";
  };
}
