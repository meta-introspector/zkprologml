# Layer 48 - Monster Prime 7 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-48-prime-7";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_48.rs -o layer_48
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_48 $out/bin/
  '';
  
  meta = {
    description = "Layer 48 computation (Monster prime 7, genus 0)";
  };
}
