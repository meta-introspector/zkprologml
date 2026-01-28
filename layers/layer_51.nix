# Layer 51 - Monster Prime 17 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-51-prime-17";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_51.rs -o layer_51
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_51 $out/bin/
  '';
  
  meta = {
    description = "Layer 51 computation (Monster prime 17, genus 0)";
  };
}
