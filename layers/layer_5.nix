# Layer 5 - Monster Prime 13 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-5-prime-13";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_5.rs -o layer_5
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_5 $out/bin/
  '';
  
  meta = {
    description = "Layer 5 computation (Monster prime 13, genus 0)";
  };
}
