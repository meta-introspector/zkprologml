# Layer 54 - Monster Prime 29 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-54-prime-29";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_54.rs -o layer_54
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_54 $out/bin/
  '';
  
  meta = {
    description = "Layer 54 computation (Monster prime 29, genus 0)";
  };
}
