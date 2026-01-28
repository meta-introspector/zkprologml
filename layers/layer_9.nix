# Layer 9 - Monster Prime 29 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-9-prime-29";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_9.rs -o layer_9
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_9 $out/bin/
  '';
  
  meta = {
    description = "Layer 9 computation (Monster prime 29, genus 0)";
  };
}
