{ pkgs ? import <nixpkgs> {} }:

let
  # All parquet files as Nix list of lists
  parquetLists = {
    search = [
      ./data/parquets/monster_search.parquet
      ./data/parquets/godel_search.parquet
      ./data/parquets/kurt_search.parquet
      ./data/parquets/umberto_search.parquet
      ./data/parquets/athena_search.parquet
      ./data/parquets/urania_search.parquet
      ./data/parquets/platonic_search.parquet
    ];
    
    lattice = [
      ./data/parquets/pnm_lattice.parquet
      ./data/parquets/keywords_pnm_lattice.parquet
    ];
  };
  
  # Flatten all parquets
  allParquets = parquetLists.search ++ parquetLists.lattice;
  
  # Pipelight pipeline for processing parquets
  pipelightConfig = pkgs.writeText "pipelight.toml" ''
    [[pipelines]]
    name = "prove_lattice"
    
    [[pipelines.steps]]
    name = "load_parquets"
    commands = [
      "echo 'Loading ${toString (builtins.length allParquets)} parquet files...'",
      ${builtins.concatStringsSep ",\n      " (map (p: ''"echo '  - ${p}'"'') allParquets)}
    ]
    
    [[pipelines.steps]]
    name = "prove_indexes"
    commands = [
      "cargo run --bin prove_lattice_indexes"
    ]
    
    [[pipelines.steps]]
    name = "prove_novelty"
    commands = [
      "swipl -g main -t halt data/proofs/perf_novelty_proof.pl"
    ]
    
    [[pipelines.steps]]
    name = "export_lean"
    commands = [
      "echo 'Exporting proofs to Lean4...'",
      "ls data/proofs/*.lean | wc -l"
    ]
  '';

in pkgs.stdenv.mkDerivation {
  name = "zkprologml-parquet-pipeline";
  
  src = ./.;
  
  buildInputs = with pkgs; [
    pipelight
    swiProlog
    rustc
    cargo
  ];
  
  buildPhase = ''
    # Copy pipelight config
    cp ${pipelightConfig} pipelight.toml
    
    # Run pipeline
    pipelight run prove_lattice
  '';
  
  installPhase = ''
    mkdir -p $out/share/zkprologml
    
    # Copy parquet lists
    echo "search:" > $out/share/zkprologml/parquet_lists.txt
    ${builtins.concatStringsSep "\n    " (map (p: ''echo "  - ${p}" >> $out/share/zkprologml/parquet_lists.txt'') parquetLists.search)}
    
    echo "lattice:" >> $out/share/zkprologml/parquet_lists.txt
    ${builtins.concatStringsSep "\n    " (map (p: ''echo "  - ${p}" >> $out/share/zkprologml/parquet_lists.txt'') parquetLists.lattice)}
    
    # Copy proofs
    cp -r data/proofs/*.lean $out/share/zkprologml/ || true
  '';
  
  meta = {
    description = "zkPrologML parquet processing pipeline";
    longDescription = ''
      Process all parquet files through pipelight pipeline:
      1. Load ${toString (builtins.length allParquets)} parquet files
      2. Prove lattice indexes
      3. Prove novelty
      4. Export to Lean4
    '';
  };
}
