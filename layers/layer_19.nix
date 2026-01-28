# Layer 19 - Monster Prime 11 (Sub-level 1)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-19-prime-11";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_19.rs -o layer_19
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_19 $out/bin/
  '';
  
  meta = {
    description = "Layer 19 computation (Monster prime 11, genus 0)";
  };
}
