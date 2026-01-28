# Layer 34 - Monster Prime 11 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-34-prime-11";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_34.rs -o layer_34
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_34 $out/bin/
  '';
  
  meta = {
    description = "Layer 34 computation (Monster prime 11, genus 0)";
  };
}
