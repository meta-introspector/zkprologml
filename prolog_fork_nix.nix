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

  # Fork each Prolog with Nix + perf recording
  forkProlog = name: impl: pkgs.stdenv.mkDerivation {
    name = "zkprologml-fork-${name}";
    src = impl;
    
    buildInputs = [ impl pkgs.swiProlog pkgs.linuxPackages.perf ];
    
    buildPhase = ''
      # Record build with perf
      echo "Forking ${name} with perf recording..."
      
      perf record -o perf_${name}.data ${pkgs.swiProlog}/bin/swipl -g "
        consult('${./data/proofs/prolog_fork_queue.pl}'),
        fork_prolog(${name}),
        halt
      " || true
      
      # Extract trace
      perf script -i perf_${name}.data > perf_${name}.trace || true
    '';
    
    installPhase = ''
      mkdir -p $out/share/zkprologml/traces
      echo "${name}" > $out/share/zkprologml/name
      echo "forked" > $out/share/zkprologml/state
      cp perf_${name}.trace $out/share/zkprologml/traces/ || true
    '';
  };

  # Patch with prime complexity ABI + ingest traces
  patchProlog = name: forked: pkgs.stdenv.mkDerivation {
    name = "zkprologml-patch-${name}";
    src = forked;
    
    buildInputs = [ pkgs.swiProlog ];
    
    buildPhase = ''
      echo "Patching ${name} with prime complexity ABI..."
      
      # Ingest perf trace
      ${pkgs.swiProlog}/bin/swipl -g "
        consult('${./data/proofs/perf_novelty_proof.pl}'),
        ingest_trace(${name}),
        halt
      " || true
      
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

  # Port to universal ABI + prove novelty
  portProlog = name: patched: pkgs.stdenv.mkDerivation {
    name = "zkprologml-port-${name}";
    src = patched;
    
    buildInputs = [ pkgs.swiProlog ];
    
    buildPhase = ''
      echo "Porting ${name} to universal ABI..."
      
      # Prove novelty against other implementations
      ${pkgs.swiProlog}/bin/swipl -g "
        consult('${./data/proofs/perf_novelty_proof.pl}'),
        prove_all_novelties,
        halt
      " || true
      
      ${pkgs.swiProlog}/bin/swipl -g "
        consult('${./data/proofs/prolog_fork_queue.pl}'),
        port_prolog(${name}),
        halt
      "
    '';
    
    installPhase = ''
      mkdir -p $out/bin $out/share/zkprologml/proofs
      cp -r $src/share/zkprologml/* $out/share/zkprologml/
      echo "ported" > $out/share/zkprologml/state
      
      # Copy novelty proofs
      cp data/proofs/novelty_*.lean $out/share/zkprologml/proofs/ || true
      
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
