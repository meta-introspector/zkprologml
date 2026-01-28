# Layer 66 - Monster Prime 17 (Sub-level 4)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-66-prime-17";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_66.rs -o layer_66
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_66 $out/bin/
  '';
  
  meta = {
    description = "Layer 66 computation (Monster prime 17, genus 0)";
  };
}
