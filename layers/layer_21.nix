# Layer 21 - Monster Prime 17 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-21-prime-17";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_21.rs -o layer_21
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_21 $out/bin/
  '';
  
  meta = {
    description = "Layer 21 computation (Monster prime 17, genus 0)";
  };
}
