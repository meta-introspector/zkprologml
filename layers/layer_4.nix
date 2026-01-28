# Layer 4 - Monster Prime 11 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-4-prime-11";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_4.rs -o layer_4
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_4 $out/bin/
  '';
  
  meta = {
    description = "Layer 4 computation (Monster prime 11, genus 0)";
  };
}
