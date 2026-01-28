% generate_llm_txt.pl - Generate llm.txt chunks for NotebookLM

:- consult('generated/merged_constants.pl').

% ═══════════════════════════════════════════════════════════
% LLM.TXT GENERATOR
% ═══════════════════════════════════════════════════════════

generate_llm_txt :-
    format('📝 Generating llm.txt...~n', []),
    
    open('generated/llm.txt', write, S),
    
    % Header
    write(S, '# zkPrologML - Zero-Knowledge Prolog Meta-Language\n\n'),
    write(S, '> Universal Prolog system with Gödel encoding, Monster group primes, and ZK proofs\n\n'),
    
    % Overview
    write(S, '## Overview\n\n'),
    write(S, 'zkPrologML unifies facts, files, functions, and proofs through:\n'),
    write(S, '- Gödel encoding (everything → prime factorization)\n'),
    write(S, '- Monster group primes (2-71)\n'),
    write(S, '- Hecke operators (sharding into 71 buckets)\n'),
    write(S, '- ZK RDF URLs (every entity is addressable)\n'),
    write(S, '- Perf data (every predicate has cycles/instructions)\n'),
    write(S, '- Query optimizer using resonance (shared prime factors)\n\n'),
    
    % Core Concepts
    write(S, '## Core Concepts\n\n'),
    write(S, '### Monster Primes\n'),
    monster_primes(Primes),
    format(S, '~w~n~n', [Primes]),
    
    write(S, '### Emoji Mappings\n'),
    forall(emoji_prime(P, E), format(S, '- ~w → ~w~n', [P, E])),
    write(S, '\n'),
    
    write(S, '### Type Encoding (Gödel)\n'),
    forall(type_prime(T, P), format(S, '- ~w → Prime ~w~n', [T, P])),
    write(S, '\n'),
    
    write(S, '### Universe Levels\n'),
    forall(universe_level(L, N), format(S, '- Level ~w: ~w~n', [L, N])),
    write(S, '\n'),
    
    % Architecture
    write(S, '## Architecture\n\n'),
    write(S, '```\n'),
    write(S, 'Facts → Gödel Numbers → Hecke Shards → ZK URLs → Proofs\n'),
    write(S, '  ↓         ↓              ↓            ↓         ↓\n'),
    write(S, 'Prolog    Prime         71 Buckets   RDFa      Lean4\n'),
    write(S, '```\n\n'),
    
    % Files
    write(S, '## Key Files\n\n'),
    write(S, '### Constants & Data\n'),
    write(S, '- `generated/merged_constants.pl` - All constants in one place (132 lines)\n'),
    write(S, '- `generated/godel_lattice.csv` - 384 entities with Gödel numbers\n'),
    write(S, '- `generated/perf_data.csv` - Performance data for 60 predicates\n'),
    write(S, '- `generated/all_constants_perf.csv` - 2,409 constants with perf\n\n'),
    
    write(S, '### Core Systems\n'),
    write(S, '- `godel_planner.pl` - Query optimizer using resonance\n'),
    write(S, '- `perf_predicates.pl` - Attach perf to every fact\n'),
    write(S, '- `find_optimizers.pl` - Use plocate to find code\n'),
    write(S, '- `auto_register_tables.pl` - Auto-discover schemas\n'),
    write(S, '- `audit_constants.sh` - Deduplicate hardcoded data\n\n'),
    
    write(S, '### Proofs\n'),
    write(S, '- `schema_of_schemas.lean` - Schema ≅ UniMath\n'),
    write(S, '- `partial_bijection.lean` - Files ⇄ Parquets ⇄ Contents\n'),
    write(S, '- `universal_unification.lean` - Everything = Everything\n'),
    write(S, '- `universe_of_universes.lean` - Universe = Parquet of Parquets\n\n'),
    
    % Usage
    write(S, '## Usage\n\n'),
    write(S, '```prolog\n'),
    write(S, '% Load constants\n'),
    write(S, '?- consult(\'generated/merged_constants.pl\').\n\n'),
    write(S, '% Get Monster primes\n'),
    write(S, '?- monster_primes(Ps).\n'),
    write(S, 'Ps = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71].\n\n'),
    write(S, '% Encode as Gödel number\n'),
    write(S, '?- godel_encode([2,3,5], G).\n'),
    write(S, 'G = 30.\n\n'),
    write(S, '% Query perf data\n'),
    write(S, '?- entity_perf(\'monster_prime/1\', C, I, M, T).\n'),
    write(S, 'C = 7442, I = 11163, M = 11, T = 3576.\n\n'),
    write(S, '% Find optimizers with plocate\n'),
    write(S, '?- find_datafusion(Files).\n'),
    write(S, 'Files = [datafusion-optimizer-43.0.0, ...].\n'),
    write(S, '```\n\n'),
    
    % Query Optimizer
    write(S, '## Query Optimizer\n\n'),
    write(S, 'Uses Gödel resonance to find optimal execution plans:\n\n'),
    write(S, '1. Encode goal as Gödel number\n'),
    write(S, '2. Find functions with shared prime factors (resonance)\n'),
    write(S, '3. Calculate cost: size × log(rows) + cycles\n'),
    write(S, '4. Sort by resonance (desc) + cost (asc)\n\n'),
    write(S, 'Lifts data from: PostgreSQL, MySQL, LLVM, MiniZinc, DataFusion\n\n'),
    
    % Stats
    write(S, '## Statistics\n\n'),
    format(S, '- Constants: 2,409 (deduplicated to 2,006, 16.72%% savings)~n', []),
    format(S, '- Perf measurements: 3,177 rows~n', []),
    format(S, '- Gödel entities: 384~n', []),
    format(S, '- Monster primes: 20~n', []),
    format(S, '- Shards: 71~n', []),
    format(S, '- Files sharded: 5,277~n', []),
    format(S, '- Total cycles: 52,171~n', []),
    format(S, '- Total instructions: 78,271~n~n', []),
    
    % Data Sources
    write(S, '## Data Sources\n\n'),
    write(S, '### Meta Parquets\n'),
    write(S, '```\n'),
    write(S, '/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/\n'),
    write(S, '├── lists_of_lists.parquet (5.8KB) - 400K parquets\n'),
    write(S, '├── locate_digest.parquet (47KB) - 3M files\n'),
    write(S, '└── meta_meta_structures.parquet (6.9KB)\n'),
    write(S, '```\n\n'),
    
    % Links
    write(S, '## Links\n\n'),
    write(S, '- GitHub: https://github.com/introspector/zkprologml\n'),
    write(S, '- HuggingFace Space: https://huggingface.co/spaces/introspector/zkprologml\n'),
    write(S, '- Dataset: https://huggingface.co/datasets/introspector/llm.txt\n\n'),
    
    close(S),
    format('✅ Generated llm.txt~n', []).

% ═══════════════════════════════════════════════════════════
% CHUNK INTO 8KB PIECES
% ═══════════════════════════════════════════════════════════

chunk_llm_txt :-
    format('📦 Chunking llm.txt...~n', []),
    
    read_file_to_string('generated/llm.txt', Content, []),
    string_length(Content, Len),
    
    ChunkSize = 8000,
    NumChunks is ceiling(Len / ChunkSize),
    format('  Total size: ~w bytes~n', [Len]),
    format('  Chunks: ~w~n', [NumChunks]),
    
    chunk_content(Content, 0, ChunkSize, 0).

chunk_content(Content, Offset, _ChunkSize, ChunkNum) :-
    string_length(Content, Len),
    Offset >= Len,
    !,
    format('✅ Created ~w chunks~n', [ChunkNum]).

chunk_content(Content, Offset, ChunkSize, ChunkNum) :-
    string_length(Content, Len),
    Remaining is Len - Offset,
    Remaining > 0,
    !,
    ActualSize is min(Remaining, ChunkSize),
    sub_string(Content, Offset, ActualSize, _, Chunk),
    format(atom(File), 'generated/llm_chunk_~w.txt', [ChunkNum]),
    open(File, write, S),
    write(S, Chunk),
    close(S),
    
    NextOffset is Offset + ChunkSize,
    NextChunk is ChunkNum + 1,
    chunk_content(Content, NextOffset, ChunkSize, NextChunk).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n📝 LLM.TXT GENERATOR~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    generate_llm_txt,
    chunk_llm_txt,
    
    format('~n✅ COMPLETE~n', []).
