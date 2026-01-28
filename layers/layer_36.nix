# Layer 36 - Monster Prime 17 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-36-prime-17";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_36.rs -o layer_36
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_36 $out/bin/
  '';
  
  meta = {
    description = "Layer 36 computation (Monster prime 17, genus 0)";
  };
}
