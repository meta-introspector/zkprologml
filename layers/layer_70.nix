# Layer 70 - Monster Prime 31 (Sub-level 4)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-70-prime-31";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_70.rs -o layer_70
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_70 $out/bin/
  '';
  
  meta = {
    description = "Layer 70 computation (Monster prime 31, genus 0)";
  };
}
