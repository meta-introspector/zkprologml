# Layer 42 - Monster Prime 47 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-42-prime-47";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_42.rs -o layer_42
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_42 $out/bin/
  '';
  
  meta = {
    description = "Layer 42 computation (Monster prime 47, genus 0)";
  };
}
