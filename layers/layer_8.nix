# Layer 8 - Monster Prime 23 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-8-prime-23";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_8.rs -o layer_8
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_8 $out/bin/
  '';
  
  meta = {
    description = "Layer 8 computation (Monster prime 23, genus 0)";
  };
}
