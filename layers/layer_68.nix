# Layer 68 - Monster Prime 23 (Sub-level 4)
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "layer-68-prime-23";
  
  src = ./.;
  
  buildInputs = with pkgs; [ rustc ];
  
  buildPhase = ''
    rustc layer_68.rs -o layer_68
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp layer_68 $out/bin/
  '';
  
  meta = {
    description = "Layer 68 computation (Monster prime 23, genus 0)";
  };
}
