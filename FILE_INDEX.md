# File Index - zkPrologML

## Core Prolog Files (data/proofs/)

### Phase 1: Prolog Variant Consumption
- `consume_prolog_variants.pl` - Main engine to consume all Prolog implementations
- `all_repos.pl` - Repository registry

### Phase 2: Galois Tower & Invariance
- `galois_tower_unification.pl` - Proves Binary ↔ Syntax ↔ Semantics ↔ Runtime invariance
- `galois_tower.pl` - Field extension tower construction
- `automorphic_orbits.pl` - Automorphic eigenvector proofs

### Phase 3: Oracle Integration (Prolog ↔ Rust Bridge)
- `oracle_prove_lattice_real.pl` - Execute real Rust lattice proofs
- `oracle_load_real_data.pl` - Load real data from Rust
- `oracle_git_history_mcts.pl` - Git history analysis via MCTS
- `oracle_map_filesystem.pl` - Filesystem mapping
- `oracle_find_syn_parser.pl` - Find syn parser in Rust code
- `oracle_substrace_syn_finder.pl` - Subtrace analysis
- `oracle_find_parquet_reader.pl` - Parquet reader discovery
- `oracle_parquet_scanner.pl` - Parquet scanning
- `prolog_rustc_bridge.pl` - Prolog ↔ rustc bridge

### Phase 4: Complexity Analysis
- `complexity_growth_proof.pl` - Prove complexity growth properties
- `complexity_lattice_key.pl` - Prime complexity lattice definition
- `dataset_complexity_binding.pl` - Bind datasets to complexity

### Phase 5: Formal Verification (Lean4)
- `71_layers_proof.lean` - 71-layer system proof
- `all_theorems.lean` - All theorem exports
- `athena_lattice.lean` - Athena lattice in Lean4
- `grand_unification.lean` - Grand unification proof
- `knuth_lean4_proofs.lean` - Knuth-style proofs
- `langlands_monster.lean` - Langlands-Monster connection
- `monster_genus_zero_induction.lean` - Monster group genus zero
- `nine_muses.lean` - Nine muses framework
- `perf_trace_monotonic.lean` - Performance trace monotonicity
- `search_proof.lean` - Search algorithm proofs
- `system_lmfdb_isomorphism.lean` - System ↔ LMFDB isomorphism
- `theorem_21.lean` - Theorem 21
- `theorem_42.lean` - Theorem 42
- `trisimulation.lean` - Trisimulation proofs
- `zkprologml_metacoq_equiv.lean` - zkPrologML ↔ MetaCoq equivalence

### Supporting Prolog Files
- `bisimulation.pl` - Bisimulation proofs
- `eco_unification.pl` - Umberto Eco-style unification
- `escher_loop.pl` - Escher strange loop
- `eternal_proof_loop.pl` - Eternal proof generation
- `eternal_fungus_spore.pl` - Self-replicating proof spores
- `fail2llm.pl` - Failure analysis for LLMs
- `fifth_generation.pl` - Fifth generation computing
- `full_spectrum_press.pl` - Full spectrum analysis
- `godel_visit.pl` - Gödel incompleteness integration
- `24h_resource_plan.pl` - 24-hour resource planning

## Rust Implementation (layer5_analysis/)

### Core Analysis Tools
- `prove_lattice_indexes.rs` - Execute lattice proofs
- `athena_lattice.rs` - Athena lattice construction
- `athena_system.rs` - Athena system implementation
- `complexity_growth_monitor.rs` - Monitor complexity growth

### Data Processing
- `consume_all_repos.rs` - Repository consumption
- `consume_parquet_git_prolog.rs` - Parquet + Git + Prolog integration
- `document_data_flow.rs` - Document data flow analysis
- `deduplicate_rust.rs` - Rust code deduplication

### Specialized Tools
- `prolog_gpu.rs` - GPU acceleration for Prolog
- `zkprologml_rust.rs` - Main Rust implementation
- `oracle_agreement.rs` - Oracle agreement verification
- `composition_theory.rs` - Composition theory
- `bootstrap_pipeline.rs` - Bootstrap pipeline
- `catalog_minizinc.rs` - MiniZinc catalog
- `generate_complexity_programs.rs` - Generate complexity test programs
- `unique_instructions.rs` - Extract unique instructions

### Search & Discovery
- `kurts_library.rs` - Kurt Gödel library search
- `search_with_parquet.rs` - Parquet-based search
- `expert_system.rs` - Expert system
- `fundamental_ontology.rs` - Ontology extraction

## Build & Configuration

- `Cargo.toml` - Main workspace configuration
- `Cargo_parallel.toml` - Parallel build configuration
- `Cargo_plocate.toml` - Plocate integration
- `shell.nix` - Nix development shell
- `eval_all_prolog.sh` - Test all Prolog files
- `run_meta_prolog.sh` - Run meta-Prolog
- `organize_data.sh` - Organize data files
- `organize_layers.sh` - Organize layer files
- `measure_build.sh` - Measure build performance

## Data Directories

- `data/proofs/` - Prolog proofs and Lean4 exports
- `data/parquets/` - Parquet data files
- `data/chords/` - Musical chord data
- `data/docs/` - Documentation
- `data/meta_prolog_traces/` - Meta-Prolog execution traces
- `data/spectrum/` - Spectrum analysis
- `data/tower/` - Galois tower data
- `layer1_terms/` - Layer 1 term extraction
- `layer2_plocate/` - Layer 2 file location
- `layer3_github/` - Layer 3 GitHub data
- `shared/` - Shared utilities

## Visualization & Output

- `prolog_gpu.html` - GPU Prolog visualization
- `zkprologml_quick.html` - Quick visualization
- `lattice_complexity_3d.html` - 3D lattice visualization
- `lattice_complexity_proof.txt` - Lattice proof output
- `prolog_eval_results.txt` - Prolog evaluation results
- `complexity_growth.csv` - Complexity growth data
- `eternal_record.log` - Eternal proof record

## MiniZinc Models

- `build_plan.dzn` - Build plan data
- `monster_lattice_weights.mzn` - Monster group lattice weights
- `search_expansion.mzn` - Search expansion model

## SQL Queries

- `lmfdb_query.sql` - LMFDB database queries
- `lmfdb_genus_zero_query.sql` - Genus zero queries

## LaTeX Documents

- `knuth_paper.tex` - Knuth-style paper

## Nix Configurations

- `24_hour_system.nix` - 24-hour system
- `fifth_generation.nix` - Fifth generation computing
- `trisimulation.nix` - Trisimulation
- `zkml_seed.nix` - zkML seed
- `lmfdb-postgres.nix` - LMFDB PostgreSQL
- `solve_build_plan.nix` - Build plan solver
- `jack_setup.nix` - JACK audio setup
- `test_mic.nix` - Microphone test

## Datalog

- `perf_data.dl` - Performance data in Datalog
