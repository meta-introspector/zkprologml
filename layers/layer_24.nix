# Layer 24 - Monster Prime 29 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-24-prime-29";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_24.rs -o layer_24
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_24 $out/bin/
  '';
  
  meta = {
    description = "Layer 24 computation (Monster prime 29, genus 0)";
  };
}
