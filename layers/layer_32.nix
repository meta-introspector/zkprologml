# Layer 32 - Monster Prime 5 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-32-prime-5";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_32.rs -o layer_32
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_32 $out/bin/
  '';
  
  meta = {
    description = "Layer 32 computation (Monster prime 5, genus 0)";
  };
}
