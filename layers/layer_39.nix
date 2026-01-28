# Layer 39 - Monster Prime 29 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-39-prime-29";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_39.rs -o layer_39
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_39 $out/bin/
  '';
  
  meta = {
    description = "Layer 39 computation (Monster prime 29, genus 0)";
  };
}
