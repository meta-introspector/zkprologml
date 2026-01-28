# Layer 18 - Monster Prime 7 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-18-prime-7";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_18.rs -o layer_18
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_18 $out/bin/
  '';
  
  meta = {
    description = "Layer 18 computation (Monster prime 7, genus 0)";
  };
}
