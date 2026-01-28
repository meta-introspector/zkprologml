# Layer 64 - Monster Prime 11 (Sub-level 4)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-64-prime-11";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_64.rs -o layer_64
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_64 $out/bin/
  '';
  
  meta = {
    description = "Layer 64 computation (Monster prime 11, genus 0)";
  };
}
