# Layer 45 - Monster Prime 2 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-45-prime-2";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_45.rs -o layer_45
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_45 $out/bin/
  '';
  
  meta = {
    description = "Layer 45 computation (Monster prime 2, genus 0)";
  };
}
