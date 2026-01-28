# Layer 14 - Monster Prime 71 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-14-prime-71";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_14.rs -o layer_14
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_14 $out/bin/
  '';
  
  meta = {
    description = "Layer 14 computation (Monster prime 71, genus 0)";
  };
}
