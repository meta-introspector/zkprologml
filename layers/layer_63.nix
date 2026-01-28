# Layer 63 - Monster Prime 7 (Sub-level 4)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-63-prime-7";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_63.rs -o layer_63
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_63 $out/bin/
  '';
  
  meta = {
    description = "Layer 63 computation (Monster prime 7, genus 0)";
  };
}
