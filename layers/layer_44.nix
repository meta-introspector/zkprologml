# Layer 44 - Monster Prime 71 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-44-prime-71";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_44.rs -o layer_44
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_44 $out/bin/
  '';
  
  meta = {
    description = "Layer 44 computation (Monster prime 71, genus 0)";
  };
}
