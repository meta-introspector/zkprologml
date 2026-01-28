# Layer 55 - Monster Prime 31 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-55-prime-31";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_55.rs -o layer_55
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_55 $out/bin/
  '';
  
  meta = {
    description = "Layer 55 computation (Monster prime 31, genus 0)";
  };
}
