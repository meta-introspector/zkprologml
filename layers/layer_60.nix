# Layer 60 - Monster Prime 2 (Sub-level 4)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-60-prime-2";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_60.rs -o layer_60
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_60 $out/bin/
  '';
  
  meta = {
    description = "Layer 60 computation (Monster prime 2, genus 0)";
  };
}
