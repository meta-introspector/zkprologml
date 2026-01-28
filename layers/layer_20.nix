# Layer 20 - Monster Prime 13 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-20-prime-13";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_20.rs -o layer_20
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_20 $out/bin/
  '';
  
  meta = {
    description = "Layer 20 computation (Monster prime 13, genus 0)";
  };
}
