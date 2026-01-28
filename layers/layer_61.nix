# Layer 61 - Monster Prime 3 (Sub-level 4)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-61-prime-3";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_61.rs -o layer_61
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_61 $out/bin/
  '';
  
  meta = {
    description = "Layer 61 computation (Monster prime 3, genus 0)";
  };
}
