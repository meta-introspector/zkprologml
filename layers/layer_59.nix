# Layer 59 - Monster Prime 71 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-59-prime-71";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_59.rs -o layer_59
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_59 $out/bin/
  '';
  
  meta = {
    description = "Layer 59 computation (Monster prime 71, genus 0)";
  };
}
