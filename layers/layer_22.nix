# Layer 22 - Monster Prime 19 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-22-prime-19";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_22.rs -o layer_22
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_22 $out/bin/
  '';
  
  meta = {
    description = "Layer 22 computation (Monster prime 19, genus 0)";
  };
}
