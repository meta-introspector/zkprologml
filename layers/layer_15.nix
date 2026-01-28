# Layer 15 - Monster Prime 2 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-15-prime-2";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_15.rs -o layer_15
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_15 $out/bin/
  '';
  
  meta = {
    description = "Layer 15 computation (Monster prime 2, genus 0)";
  };
}
