# Layer 26 - Monster Prime 41 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-26-prime-41";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_26.rs -o layer_26
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_26 $out/bin/
  '';
  
  meta = {
    description = "Layer 26 computation (Monster prime 41, genus 0)";
  };
}
