# Layer 3 - Monster Prime 7 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-3-prime-7";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_3.rs -o layer_3
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_3 $out/bin/
  '';
  
  meta = {
    description = "Layer 3 computation (Monster prime 7, genus 0)";
  };
}
