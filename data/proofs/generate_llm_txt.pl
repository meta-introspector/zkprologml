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
    write(S, '- Perf data (every predicate has cycles/instructions)\n\n'),
    
    % Core Concepts
    write(S, '## Core Concepts\n\n'),
    write(S, '### Monster Primes\n'),
    monster_primes(Primes),
    format(S, '~w~n~n', [Primes]),
    
    write(S, '### Emoji Mappings\n'),
    forall(emoji_prime(P, E), format(S, '- ~w → ~w~n', [P, E])),
    write(S, '\n'),
    
    write(S, '### Type Encoding\n'),
    forall(type_prime(T, P), format(S, '- ~w → Prime ~w~n', [T, P])),
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
    write(S, '- `generated/merged_constants.pl` - All constants in one place\n'),
    write(S, '- `generated/godel_lattice.csv` - 384 entities with Gödel numbers\n'),
    write(S, '- `generated/perf_data.csv` - Performance data for all predicates\n'),
    write(S, '- `godel_planner.pl` - Query optimizer using resonance\n'),
    write(S, '- `perf_predicates.pl` - Attach perf to every fact\n\n'),
    
    % Usage
    write(S, '## Usage\n\n'),
    write(S, '```prolog\n'),
    write(S, '% Load constants\n'),
    write(S, '?- consult(\'generated/merged_constants.pl\').\n\n'),
    write(S, '% Get Monster primes\n'),
    write(S, '?- monster_primes(Ps).\n\n'),
    write(S, '% Encode as Gödel number\n'),
    write(S, '?- godel_encode([2,3,5], G).\n'),
    write(S, 'G = 30.\n\n'),
    write(S, '% Query perf data\n'),
    write(S, '?- entity_perf(\'monster_prime/1\', C, I, M, T).\n'),
    write(S, '```\n\n'),
    
    % Stats
    write(S, '## Statistics\n\n'),
    format(S, '- Constants: 2,409 (deduplicated to 2,006)~n', []),
    format(S, '- Perf measurements: 3,177 rows~n', []),
    format(S, '- Gödel entities: 384~n', []),
    format(S, '- Monster primes: 20~n', []),
    format(S, '- Shards: 71~n~n', []),
    
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
