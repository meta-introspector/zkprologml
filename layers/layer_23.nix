# Layer 23 - Monster Prime 23 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-23-prime-23";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_23.rs -o layer_23
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_23 $out/bin/
  '';
  
  meta = {
    description = "Layer 23 computation (Monster prime 23, genus 0)";
  };
}
