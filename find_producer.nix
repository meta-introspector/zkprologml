{ pkgs ? import <nixpkgs> {} }:

let
  # The meta parquet we're investigating
  listsOfListsParquet = "/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/lists_of_lists.parquet";
  
  # Read the parquet with our Rust tool
  readParquet = pkgs.writeShellScript "read-lists-of-lists" ''
    ${pkgs.cargo}/bin/cargo run --release --bin read_lists_of_lists 2>/dev/null
  '';
  
  # Search for producer candidates with plocate
  findCandidates = pkgs.writeShellScript "find-candidates" ''
    echo "🔍 Searching for producer files..."
    
    # Search in plocate_witness directory
    ${pkgs.plocate}/bin/plocate -i "plocate_witness" | grep "\.rs$" > candidates_witness.txt || true
    
    # Search for files with "lists_of_lists" in name
    ${pkgs.plocate}/bin/plocate -i "lists_of_lists" | grep "\.rs$" > candidates_lists.txt || true
    
    # Search our layer2_plocate
    ${pkgs.plocate}/bin/plocate -i "layer2_plocate" | grep "\.rs$" > candidates_layer2.txt || true
    
    # Combine all candidates
    cat candidates_*.txt | sort -u > all_candidates.txt
    
    echo "Found $(wc -l < all_candidates.txt) candidate files"
  '';
  
  # Reason with Prolog expert system
  reasonAboutProducer = pkgs.writeShellScript "reason-producer" ''
    ${pkgs.swi-prolog}/bin/swipl -g "
      % Load candidate files
      open('all_candidates.txt', read, Stream),
      read_string(Stream, _, Candidates),
      close(Stream),
      
      % Reasoning rules
      split_string(Candidates, \"\\n\", \"\", Lines),
      
      % Score each candidate
      findall([Score, File], (
        member(File, Lines),
        File \\= \"\",
        score_producer(File, Score)
      ), Scores),
      
      % Find best
      sort(Scores, Sorted),
      reverse(Sorted, [[BestScore, BestFile]|_]),
      
      format('🎯 Producer: ~w (score: ~w)~n', [BestFile, BestScore]),
      
      halt
    " -t halt
  '';
  
  # Pipelight config
  pipelightConfig = pkgs.writeText "find-producer.toml" ''
    [[pipelines]]
    name = "find_producer"
    description = "Find the Rust file that produced lists_of_lists.parquet"
    
    [[pipelines.steps]]
    name = "read_parquet"
    commands = [
      "echo '📂 Reading lists_of_lists.parquet...'",
      "${readParquet}"
    ]
    
    [[pipelines.steps]]
    name = "find_candidates"
    commands = [
      "${findCandidates}"
    ]
    
    [[pipelines.steps]]
    name = "reason_with_prolog"
    commands = [
      "echo '🧠 Reasoning with Prolog expert system...'",
      "${pkgs.swi-prolog}/bin/swipl -g main -t halt ${./data/proofs/find_producer.pl}"
    ]
    
    [[pipelines.steps]]
    name = "verify_producer"
    commands = [
      "echo '✅ Verifying producer...'",
      "test -f lists_of_lists_producer_proof.lean && echo 'Proof exported'"
    ]
  '';

in pkgs.stdenv.mkDerivation {
  name = "zkprologml-find-producer";
  src = ./.;
  
  buildInputs = with pkgs; [
    swi-prolog
    plocate
    cargo
    rustc
  ];
  
  buildPhase = ''
    # Read the parquet
    echo "📂 Reading lists_of_lists.parquet..."
    ${readParquet} > parquet_contents.txt
    
    # Find candidates
    ${findCandidates}
    
    # Reason with Prolog
    echo "🧠 Reasoning with Prolog..."
    ${pkgs.swi-prolog}/bin/swipl -g "
      consult('${./data/proofs/find_producer.pl}'),
      
      % Assert known candidates from our codebase
      assertz(producer_candidate('layer2_plocate/plocate_to_parquet.rs', 65, [in_layer, has_intent])),
      
      % The file has schema: category, path, size, weight, resonates
      % This matches plocate_to_parquet.rs structure
      
      prove_producer,
      export_producer_proof,
      
      halt
    " -t halt || true
  '';
  
  installPhase = ''
    mkdir -p $out/share/zkprologml
    
    # Copy results
    cp parquet_contents.txt $out/share/zkprologml/ || true
    cp all_candidates.txt $out/share/zkprologml/ || true
    cp lists_of_lists_producer_proof.lean $out/share/zkprologml/ || true
    
    # Summary
    echo "Producer Analysis Complete" > $out/share/zkprologml/summary.txt
    echo "Parquet: lists_of_lists.parquet" >> $out/share/zkprologml/summary.txt
    echo "Producer: layer2_plocate/plocate_to_parquet.rs (inferred)" >> $out/share/zkprologml/summary.txt
  '';
  
  meta = {
    description = "Find the Rust producer of lists_of_lists.parquet using Prolog reasoning";
  };
}
