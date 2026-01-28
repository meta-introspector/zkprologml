# Layer 40 - Monster Prime 31 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-40-prime-31";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_40.rs -o layer_40
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_40 $out/bin/
  '';
  
  meta = {
    description = "Layer 40 computation (Monster prime 31, genus 0)";
  };
}
