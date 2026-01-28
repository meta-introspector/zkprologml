# Layer 58 - Monster Prime 59 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-58-prime-59";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_58.rs -o layer_58
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_58 $out/bin/
  '';
  
  meta = {
    description = "Layer 58 computation (Monster prime 59, genus 0)";
  };
}
