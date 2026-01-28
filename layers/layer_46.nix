# Layer 46 - Monster Prime 3 (Sub-level 3)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-46-prime-3";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_46.rs -o layer_46
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_46 $out/bin/
  '';
  
  meta = {
    description = "Layer 46 computation (Monster prime 3, genus 0)";
  };
}
