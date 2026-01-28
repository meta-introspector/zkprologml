# Layer 33 - Monster Prime 7 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-33-prime-7";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_33.rs -o layer_33
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_33 $out/bin/
  '';
  
  meta = {
    description = "Layer 33 computation (Monster prime 7, genus 0)";
  };
}
