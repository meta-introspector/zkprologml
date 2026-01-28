# Layer 13 - Monster Prime 59 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-13-prime-59";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_13.rs -o layer_13
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_13 $out/bin/
  '';
  
  meta = {
    description = "Layer 13 computation (Monster prime 59, genus 0)";
  };
}
