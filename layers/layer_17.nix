# Layer 17 - Monster Prime 5 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-17-prime-5";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_17.rs -o layer_17
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_17 $out/bin/
  '';
  
  meta = {
    description = "Layer 17 computation (Monster prime 5, genus 0)";
  };
}
