# Layer 10 - Monster Prime 31 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-10-prime-31";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_10.rs -o layer_10
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_10 $out/bin/
  '';
  
  meta = {
    description = "Layer 10 computation (Monster prime 31, genus 0)";
  };
}
