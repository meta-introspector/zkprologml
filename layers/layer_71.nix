# Layer 71 - Monster Prime 41 (Sub-level 4)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-71-prime-41";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_71.rs -o layer_71
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_71 $out/bin/
  '';
  
  meta = {
    description = "Layer 71 computation (Monster prime 41, genus 0)";
  };
}
