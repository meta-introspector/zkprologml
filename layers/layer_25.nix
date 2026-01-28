# Layer 25 - Monster Prime 31 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-25-prime-31";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_25.rs -o layer_25
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_25 $out/bin/
  '';
  
  meta = {
    description = "Layer 25 computation (Monster prime 31, genus 0)";
  };
}
