# Layer 53 - Monster Prime 23 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-53-prime-23";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_53.rs -o layer_53
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_53 $out/bin/
  '';
  
  meta = {
    description = "Layer 53 computation (Monster prime 23, genus 0)";
  };
}
