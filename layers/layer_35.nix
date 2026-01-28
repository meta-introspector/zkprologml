# Layer 35 - Monster Prime 13 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-35-prime-13";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_35.rs -o layer_35
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_35 $out/bin/
  '';
  
  meta = {
    description = "Layer 35 computation (Monster prime 13, genus 0)";
  };
}
