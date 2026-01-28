# Layer 30 - Monster Prime 2 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-30-prime-2";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_30.rs -o layer_30
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_30 $out/bin/
  '';
  
  meta = {
    description = "Layer 30 computation (Monster prime 2, genus 0)";
  };
}
