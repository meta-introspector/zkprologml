# Layer 7 - Monster Prime 19 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-7-prime-19";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_7.rs -o layer_7
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_7 $out/bin/
  '';
  
  meta = {
    description = "Layer 7 computation (Monster prime 19, genus 0)";
  };
}
