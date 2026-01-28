# Layer 31 - Monster Prime 3 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-31-prime-3";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_31.rs -o layer_31
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_31 $out/bin/
  '';
  
  meta = {
    description = "Layer 31 computation (Monster prime 3, genus 0)";
  };
}
