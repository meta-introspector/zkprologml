# Layer 41 - Monster Prime 41 (Sub-level 2)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-41-prime-41";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_41.rs -o layer_41
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_41 $out/bin/
  '';
  
  meta = {
    description = "Layer 41 computation (Monster prime 41, genus 0)";
  };
}
