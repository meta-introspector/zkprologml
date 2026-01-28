# Layer 0 - Monster Prime 2 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-0-prime-2";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_0.rs -o layer_0
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_0 $out/bin/
  '';
  
  meta = {
    description = "Layer 0 computation (Monster prime 2, genus 0)";
  };
}
