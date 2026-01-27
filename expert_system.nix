{ pkgs ? import <nixpkgs> {} }:

let
  # All parquet files
  parquets = {
    monster = ./data/parquets/monster_search.parquet;
    godel = ./data/parquets/godel_search.parquet;
    kurt = ./data/parquets/kurt_search.parquet;
    umberto = ./data/parquets/umberto_search.parquet;
    athena = ./data/parquets/athena_search.parquet;
    urania = ./data/parquets/urania_search.parquet;
    platonic = ./data/parquets/platonic_search.parquet;
    pnm_lattice = ./data/parquets/pnm_lattice.parquet;
    keywords = ./data/parquets/keywords_pnm_lattice.parquet;
  };
  
  # Sample a parquet with DuckDB
  sampleParquet = name: file: pkgs.writeShellScript "sample-${name}" ''
    echo "📊 Sampling ${name}..."
    ${pkgs.duckdb}/bin/duckdb -c "
      SELECT * FROM read_parquet('${file}') 
      LIMIT 100
    " > sample_${name}.txt
    echo "✅ Sampled ${name}: $(wc -l < sample_${name}.txt) rows"
  '';
  
  # Evaluate concept with Prolog
  evaluateConcept = name: pkgs.writeShellScript "evaluate-${name}" ''
    echo "🔬 Evaluating ${name}..."
    ${pkgs.swi-prolog}/bin/swipl -g "
      consult('${./data/proofs/expert_system_models.pl}'),
      assertz(sample(${name}, 100, [])),
      evaluate_concept(${name}),
      halt
    "
  '';
  
  # Build model
  buildModel = name: pkgs.writeShellScript "build-model-${name}" ''
    echo "🏗️  Building model for ${name}..."
    ${pkgs.swi-prolog}/bin/swipl -g "
      consult('${./data/proofs/expert_system_models.pl}'),
      assertz(sample(${name}, 100, [])),
      assertz(evaluation(${name}, high, [], 100)),
      build_model(${name}),
      halt
    "
  '';
  
  # Pipelight config for all concepts
  pipelightConfig = pkgs.writeText "pipelight-expert.toml" ''
    [[pipelines]]
    name = "expert_system"
    description = "Sample, evaluate, model all concepts"
    
    ${builtins.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (name: file: ''
      [[pipelines.steps]]
      name = "sample_${name}"
      commands = ["${sampleParquet name file}"]
      
      [[pipelines.steps]]
      name = "evaluate_${name}"
      commands = ["${evaluateConcept name}"]
      
      [[pipelines.steps]]
      name = "model_${name}"
      commands = ["${buildModel name}"]
    '') parquets)}
    
    [[pipelines.steps]]
    name = "export_all"
    commands = [
      "echo '📝 Exporting all models to Lean4...'",
      "ls data/proofs/model_*.lean | wc -l"
    ]
  '';

in pkgs.stdenv.mkDerivation {
  name = "zkprologml-expert-system";
  src = ./.;
  
  buildInputs = with pkgs; [
    pipelight
    duckdb
    swi-prolog
  ];
  
  buildPhase = ''
    # Copy pipelight config
    cp ${pipelightConfig} pipelight.toml
    
    # Run samples with DuckDB directly
    ${builtins.concatStringsSep "\n    " (pkgs.lib.mapAttrsToList (name: file: 
      "${sampleParquet name file}"
    ) parquets)}
    
    # Run evaluations
    ${builtins.concatStringsSep "\n    " (pkgs.lib.mapAttrsToList (name: file:
      "${evaluateConcept name}"
    ) parquets)}
    
    # Build models
    ${builtins.concatStringsSep "\n    " (pkgs.lib.mapAttrsToList (name: file:
      "${buildModel name}"
    ) parquets)}
  '';
  
  installPhase = ''
    mkdir -p $out/share/zkprologml/models
    
    # Copy all samples
    cp sample_*.txt $out/share/zkprologml/ || true
    
    # Copy all models
    cp data/proofs/model_*.lean $out/share/zkprologml/models/ || true
    
    # Summary
    echo "Expert System Results:" > $out/share/zkprologml/summary.txt
    echo "Concepts: ${toString (builtins.length (builtins.attrNames parquets))}" >> $out/share/zkprologml/summary.txt
    ls $out/share/zkprologml/models/*.lean | wc -l >> $out/share/zkprologml/summary.txt
  '';
  
  meta = {
    description = "Expert system for concept modeling from parquets";
  };
}
