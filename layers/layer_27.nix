# Layer 27 - Monster Prime 47 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-27-prime-47";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_27.rs -o layer_27
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_27 $out/bin/
  '';
  
  meta = {
    description = "Layer 27 computation (Monster prime 47, genus 0)";
  };
}
