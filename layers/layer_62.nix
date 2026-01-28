# Layer 62 - Monster Prime 5 (Sub-level 4)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-62-prime-5";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_62.rs -o layer_62
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_62 $out/bin/
  '';
  
  meta = {
    description = "Layer 62 computation (Monster prime 5, genus 0)";
  };
}
