# Layer 28 - Monster Prime 59 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-28-prime-59";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_28.rs -o layer_28
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_28 $out/bin/
  '';
  
  meta = {
    description = "Layer 28 computation (Monster prime 59, genus 0)";
  };
}
