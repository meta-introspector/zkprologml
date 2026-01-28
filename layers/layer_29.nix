# Layer 29 - Monster Prime 71 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-29-prime-71";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_29.rs -o layer_29
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_29 $out/bin/
  '';
  
  meta = {
    description = "Layer 29 computation (Monster prime 71, genus 0)";
  };
}
