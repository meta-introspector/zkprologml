# File Categorization and Duplication Analysis

## Categories

### 1. Search & Indexing (7 files)
- `search_plocate_terms.rs` - Search using plocate
- `search_with_parquet.rs` - Search parquet files
- `plocate_to_parquet.rs` - Convert plocate to parquet
- `collect_all_to_parquet.rs` - Collect all terms to parquet ⭐ KEEP
- `athena_to_parquet.rs` - Athena-specific (DUPLICATE?)
- `github_repo_finder.rs` - Find GitHub repos
- `index_files.rs` - Index files (this tool)

**Potential duplicates**: athena_to_parquet vs collect_all_to_parquet

### 2. P×N×M Lattice (5 files)
- `parallel_scan.rs` - Parallel scanner with chords
- `prime_resonance.rs` - Prime sampling
- `ngram_lattice.rs` - N-gram extraction
- `pnm_lattice_sampler.rs` - P×N×M sampler
- `pnm_to_parquet.rs` - P×N×M to parquet ⭐ KEEP

### 3. Layer Generation (2 files)
- `generate_71_layers.rs` - Generate 71 layers
- `generate_layer_cells.rs` - Generate layer cells ⭐ KEEP

**Potential duplicates**: These might overlap

### 4. Analysis & Extraction (5 files)
- `extract_perf_traces.rs` - Extract from perf traces
- `extract_terms.rs` - Extract terms from parquet
- `rank_terms.rs` - Rank terms by frequency
- `construct_orbits.rs` - Construct byte orbits
- `deduplicate_rust.rs` - Deduplicate files

### 5. Proof & Verification (4 files)
- `prove_complexity_increases.rs` - Prove monotonic complexity
- `prove_lattice_indexes.rs` - Prove lattice indexes
- `simple_proof.rs` - Simple proof
- `knuth_verifier.rs` - Knuth verification

### 6. Theory & Systems (8 files)
- `composition_theory.rs` - System composition theory
- `system_lmfdb_isomorphism.rs` - System ≅ LMFDB
- `langlands_monster_integration.rs` - Langlands + Monster
- `monster_genus_zero_solver.rs` - Monster genus 0
- `lmfdb_monster_sharding.rs` - LMFDB sharding
- `athena_system.rs` - Athena's eigenvector
- `kurts_library.rs` - Kurt's Gödel library
- `build_predictor.rs` - Build predictor

### 7. Self-* Systems (4 files)
- `self_aware_search.rs` - Self-aware search
- `self_describing_system.rs` - Self-describing
- `self_expand_search.rs` - Self-expanding search
- `self_expanding_research.rs` - Self-expanding research

**Potential duplicates**: self_expand_search vs self_expanding_research

### 8. Agents & Cards (4 files)
- `umberto_eco_scholars.rs` - 24 Umberto scholars
- `multi_process_trading.rs` - Multi-process trading
- `add_athena.rs` - Add Athena
- `add_urania.rs` - Add Urania

### 9. Deep Q & Prediction (1 file)
- `deep_q_predictor.rs` - Deep Q-Network

## Duplication Candidates

### High Priority (Check These)
1. **athena_to_parquet.rs** vs **collect_all_to_parquet.rs**
   - Both convert searches to parquet
   - collect_all is more general

2. **self_expand_search.rs** vs **self_expanding_research.rs**
   - Both do self-expansion
   - Need to check which is better

3. **generate_71_layers.rs** vs **generate_layer_cells.rs**
   - Both generate layers
   - layer_cells is more complete (360 files)

### Medium Priority
4. **prove_lattice_indexes.rs** vs **simple_proof.rs**
   - Both prove lattice properties
   - simple_proof is simpler

5. **search_plocate_terms.rs** vs **search_with_parquet.rs**
   - Different approaches to search

## Recommendations

### Keep (Core Tools)
- `collect_all_to_parquet.rs` - Main parquet collector
- `pnm_to_parquet.rs` - P×N×M lattice
- `generate_layer_cells.rs` - Complete layer generator
- `extract_terms.rs` + `rank_terms.rs` - Analysis pipeline
- `umberto_eco_scholars.rs` - Card system
- `deep_q_predictor.rs` - Prediction
- `system_lmfdb_isomorphism.rs` - Main theory

### Review for Removal
- `athena_to_parquet.rs` - Superseded by collect_all
- `self_expand_search.rs` - Check vs self_expanding_research
- `generate_71_layers.rs` - Superseded by generate_layer_cells
- `simple_proof.rs` - Superseded by prove_lattice_indexes
- `search_plocate_terms.rs` - Old search method

### Total: 40 files → ~30 files after cleanup
