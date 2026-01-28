# Layer 69 - Monster Prime 29 (Sub-level 4)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-69-prime-29";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_69.rs -o layer_69
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_69 $out/bin/
  '';
  
  meta = {
    description = "Layer 69 computation (Monster prime 29, genus 0)";
  };
}
