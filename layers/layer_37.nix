# Layer 37 - Monster Prime 19 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-37-prime-19";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_37.rs -o layer_37
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_37 $out/bin/
  '';
  
  meta = {
    description = "Layer 37 computation (Monster prime 19, genus 0)";
  };
}
