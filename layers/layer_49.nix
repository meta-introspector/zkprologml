# Layer 49 - Monster Prime 11 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-49-prime-11";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_49.rs -o layer_49
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_49 $out/bin/
  '';
  
  meta = {
    description = "Layer 49 computation (Monster prime 11, genus 0)";
  };
}
