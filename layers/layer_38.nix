# Layer 38 - Monster Prime 23 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-38-prime-23";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_38.rs -o layer_38
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_38 $out/bin/
  '';
  
  meta = {
    description = "Layer 38 computation (Monster prime 23, genus 0)";
  };
}
