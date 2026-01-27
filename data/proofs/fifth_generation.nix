{ pkgs ? import <nixpkgs> {} }:

let
  # Pure LLM: Local model (deterministic, content-addressed)
  pureLLM = prompt: pkgs.stdenv.mkDerivation {
    name = "pure-llm-response";
    buildInputs = [ pkgs.ollama ];
    
    # Fixed-output derivation
    outputHashMode = "flat";
    outputHashAlgo = "sha256";
    outputHash = pkgs.lib.fakeSha256;  # Replace with actual hash
    
    buildPhase = ''
      # Start ollama server
      ollama serve &
      OLLAMA_PID=$!
      sleep 2
      
      # Pull model (cached in Nix store)
      ollama pull llama3.2:1b
      
      # Run inference (deterministic: temperature = 0)
      ollama run llama3.2:1b --temperature 0.0 "${prompt}" > response.txt
      
      # Stop server
      kill $OLLAMA_PID
    '';
    
    installPhase = ''
      cp response.txt $out
    '';
  };
  
  # Impure LLM: External API (non-deterministic, side effects)
  impureLLM = prompt: pkgs.stdenv.mkDerivation {
    name = "impure-llm-response";
    buildInputs = [ pkgs.curl pkgs.jq ];
    
    # Impure derivation (network access)
    __impure = true;
    
    buildPhase = ''
      # Call external API
      curl -X POST https://api.anthropic.com/v1/messages \
        -H "Content-Type: application/json" \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -d '{
          "model": "claude-3-5-sonnet-20241022",
          "messages": [{
            "role": "user",
            "content": "'"${prompt}"'"
          }],
          "max_tokens": 1024
        }' > response.json
      
      # Extract response
      jq -r '.content[0].text' response.json > response.txt
      
      # Save metadata
      jq '{id, model, usage}' response.json > metadata.json
    '';
    
    installPhase = ''
      mkdir -p $out
      cp response.txt $out/
      cp metadata.json $out/
    '';
  };
  
  # Example: LLM generates code
  llmGeneratedCode = pureLLM "Generate a Rust function to compute factorial. Return only code, no explanation.";
  
  # Example: Build the generated code
  rustBuild = pkgs.rustPlatform.buildRustPackage {
    pname = "llm-generated-factorial";
    version = "0.1.0";
    src = pkgs.writeTextDir "src/main.rs" (builtins.readFile llmGeneratedCode);
    cargoLock.lockFile = pkgs.writeText "Cargo.lock" "";
  };
  
  # Example: Measure with perf
  perfMeasure = pkgs.runCommand "perf-measure" {
    buildInputs = [ pkgs.linuxPackages.perf ];
  } ''
    perf stat -e cycles,instructions,cache-misses -o $out \
      ${rustBuild}/bin/factorial 2>&1 || true
  '';
  
  # Example: Prolog reasons about the pipeline
  prologReasoning = pkgs.runCommand "prolog-reasoning" {
    buildInputs = [ pkgs.swiProlog ];
  } ''
    cat > reasoning.pl << 'EOF'
:- ['data/proofs/fifth_generation.pl'].
:- prove_fifth_generation.
:- halt.
EOF
    
    swipl -q -f reasoning.pl > $out
  '';

in {
  inherit pureLLM impureLLM llmGeneratedCode rustBuild perfMeasure prologReasoning;
  
  # The complete fifth generation pipeline
  pipeline = pkgs.runCommand "fifth-gen-pipeline" {} ''
    mkdir -p $out
    
    echo "Fifth Generation Pipeline" > $out/README.md
    echo "=========================" >> $out/README.md
    echo "" >> $out/README.md
    echo "1. LLM generates code: ${llmGeneratedCode}" >> $out/README.md
    echo "2. Nix builds code: ${rustBuild}" >> $out/README.md
    echo "3. Perf measures: ${perfMeasure}" >> $out/README.md
    echo "4. Prolog reasons: ${prologReasoning}" >> $out/README.md
    echo "" >> $out/README.md
    echo "Pure LLM: Content-addressed, deterministic" >> $out/README.md
    echo "Impure LLM: External API, latest knowledge" >> $out/README.md
  '';
}
