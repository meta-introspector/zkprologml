# Layer 12 - Monster Prime 47 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-12-prime-47";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_12.rs -o layer_12
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_12 $out/bin/
  '';
  
  meta = {
    description = "Layer 12 computation (Monster prime 47, genus 0)";
  };
}
