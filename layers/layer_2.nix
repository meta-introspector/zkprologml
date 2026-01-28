# Layer 2 - Monster Prime 5 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-2-prime-5";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_2.rs -o layer_2
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_2 $out/bin/
  '';
  
  meta = {
    description = "Layer 2 computation (Monster prime 5, genus 0)";
  };
}
