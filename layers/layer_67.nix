# Layer 67 - Monster Prime 19 (Sub-level 4)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-67-prime-19";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_67.rs -o layer_67
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_67 $out/bin/
  '';
  
  meta = {
    description = "Layer 67 computation (Monster prime 19, genus 0)";
  };
}
