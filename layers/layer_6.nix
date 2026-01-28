# Layer 6 - Monster Prime 17 (Sub-level 0)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-6-prime-17";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_6.rs -o layer_6
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_6 $out/bin/
  '';
  
  meta = {
    description = "Layer 6 computation (Monster prime 17, genus 0)";
  };
}
