# Layer 50 - Monster Prime 13 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-50-prime-13";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_50.rs -o layer_50
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_50 $out/bin/
  '';
  
  meta = {
    description = "Layer 50 computation (Monster prime 13, genus 0)";
  };
}
