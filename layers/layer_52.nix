# Layer 52 - Monster Prime 19 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-52-prime-19";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_52.rs -o layer_52
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_52 $out/bin/
  '';
  
  meta = {
    description = "Layer 52 computation (Monster prime 19, genus 0)";
  };
}
