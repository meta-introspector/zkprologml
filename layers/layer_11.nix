# Layer 11 - Monster Prime 41 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-11-prime-41";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_11.rs -o layer_11
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_11 $out/bin/
  '';
  
  meta = {
    description = "Layer 11 computation (Monster prime 41, genus 0)";
  };
}
