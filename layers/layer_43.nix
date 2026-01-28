# Layer 43 - Monster Prime 59 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-43-prime-59";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_43.rs -o layer_43
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_43 $out/bin/
  '';
  
  meta = {
    description = "Layer 43 computation (Monster prime 59, genus 0)";
  };
}
