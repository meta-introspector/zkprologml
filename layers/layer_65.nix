# Layer 65 - Monster Prime 13 (Sub-level 4)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-65-prime-13";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_65.rs -o layer_65
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_65 $out/bin/
  '';
  
  meta = {
    description = "Layer 65 computation (Monster prime 13, genus 0)";
  };
}
