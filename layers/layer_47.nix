# Layer 47 - Monster Prime 5 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-47-prime-5";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_47.rs -o layer_47
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_47 $out/bin/
  '';
  
  meta = {
    description = "Layer 47 computation (Monster prime 5, genus 0)";
  };
}
