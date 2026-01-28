# Layer 56 - Monster Prime 41 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-56-prime-41";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_56.rs -o layer_56
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_56 $out/bin/
  '';
  
  meta = {
    description = "Layer 56 computation (Monster prime 41, genus 0)";
  };
}
