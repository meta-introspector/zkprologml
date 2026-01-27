{ pkgs ? import <nixpkgs> {} }:

let
  # All Prolog implementations via Nix
  prologImpls = {
    scryer = pkgs.scryer-prolog;
    swi = pkgs.swiProlog;
    gnu = pkgs.gprolog;
    trealla = pkgs.trealla;
    # Others need custom derivations
  };

  # Fork each Prolog with Nix
  forkProlog = name: impl: pkgs.stdenv.mkDerivation {
    name = "zkprologml-fork-${name}";
    src = impl;
    
    buildInputs = [ impl pkgs.swiProlog ];
    
    buildPhase = ''
      # Extract predicates from implementation
      echo "Forking ${name}..."
      
      # Analyze with SWI-Prolog
      ${pkgs.swiProlog}/bin/swipl -g "
        consult('${./data/proofs/prolog_fork_queue.pl}'),
        fork_prolog(${name}),
        halt
      "
    '';
    
    installPhase = ''
      mkdir -p $out/share/zkprologml
      echo "${name}" > $out/share/zkprologml/name
      echo "forked" > $out/share/zkprologml/state
    '';
  };

  # Patch with prime complexity ABI
  patchProlog = name: forked: pkgs.stdenv.mkDerivation {
    name = "zkprologml-patch-${name}";
    src = forked;
    
    buildPhase = ''
      echo "Patching ${name} with prime complexity ABI..."
      
      ${pkgs.swiProlog}/bin/swipl -g "
        consult('${./data/proofs/prolog_fork_queue.pl}'),
        patch_prolog(${name}),
        halt
      "
    '';
    
    installPhase = ''
      mkdir -p $out/share/zkprologml
      cp -r $src/share/zkprologml/* $out/share/zkprologml/
      echo "patched" > $out/share/zkprologml/state
    '';
  };

  # Port to universal ABI
  portProlog = name: patched: pkgs.stdenv.mkDerivation {
    name = "zkprologml-port-${name}";
    src = patched;
    
    buildPhase = ''
      echo "Porting ${name} to universal ABI..."
      
      ${pkgs.swiProlog}/bin/swipl -g "
        consult('${./data/proofs/prolog_fork_queue.pl}'),
        port_prolog(${name}),
        halt
      "
    '';
    
    installPhase = ''
      mkdir -p $out/bin $out/share/zkprologml
      cp -r $src/share/zkprologml/* $out/share/zkprologml/
      echo "ported" > $out/share/zkprologml/state
      
      # Generate universal_call wrapper
      cat > $out/bin/universal_call_${name} <<EOF
#!/bin/sh
${pkgs.swiProlog}/bin/swipl -g "universal_call(${name}, \$1, \$2, \$3)" -t halt
EOF
      chmod +x $out/bin/universal_call_${name}
    '';
  };

  # Pipeline: fork -> patch -> port
  processPrologImpl = name: impl:
    let
      forked = forkProlog name impl;
      patched = patchProlog name forked;
      ported = portProlog name patched;
    in ported;

  # Process all available implementations
  allPorted = pkgs.lib.mapAttrs processPrologImpl prologImpls;

in pkgs.buildEnv {
  name = "zkprologml-all-prologs";
  paths = pkgs.lib.attrValues allPorted;
  
  meta = {
    description = "All Prolog implementations unified via prime complexity ABI";
    longDescription = ''
      zkPrologML: Universal Prolog system
      - Forks all Prolog implementations
      - Patches with prime complexity ABI
      - Ports to universal_call/4 interface
      
      Available: ${builtins.concatStringsSep ", " (pkgs.lib.attrNames allPorted)}
    '';
  };
}
