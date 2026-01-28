# SEARCH SOPs - Standard Operating Procedures for Finding Data

## Rule 1: ALWAYS Check Our Own Code First

Before searching externally:
1. Read `lists_of_lists_meta.pl` - Contains ALL parquet locations
2. Read `README.md` - Project overview
3. Read `SESSION_*_SUMMARY.md` - What we've built
4. Use `code` tool to search symbols
5. Use `grep` to search our Prolog files

## Rule 2: Known Data Locations

### Meta Parquets (The Source of Truth)
```
/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/
├── lists_of_lists.parquet     # 400K parquets
├── locate_digest.parquet       # 3M files  
└── meta_meta_structures.parquet
```

### Our Generated Data
```
data/proofs/generated/
├── godel_lattice.csv           # 384 entities
├── hecke_shards_rust.csv       # 384 sharded
├── files_enriched_monster.csv  # 5,277 files with Monster numbers
├── all_files_sharded.csv       # 5,277 files sharded
└── *.parquet                   # Parquet versions
```

### Our Repos
```
data/proofs/repos/
├── coq-of-rust/
├── coq-of-ocaml/
├── compcert/
└── coq-of-ts/
```

## Rule 3: Search Order

1. **Check lists_of_lists_meta.pl**
   ```prolog
   ?- consult('data/proofs/lists_of_lists_meta.pl').
   ?- meta_parquet(File).
   ```

2. **Use our auto-register system**
   ```prolog
   ?- consult('data/proofs/auto_register_tables.pl').
   ?- auto_register_all.
   ```

3. **Query our facts**
   ```prolog
   ?- consult('data/proofs/reason_facts.pl').
   ?- entity(71, Type, Path, Primes).
   ```

4. **Use native Rust Prolog**
   ```bash
   cd data/proofs && ./prolog_parquet
   ```

## Rule 4: Never Fake Numbers

- If we don't know: SAY "I don't know, let me check"
- If data is in parquet: USE the parquet
- If count is uncertain: COUNT it properly
- If file doesn't exist: DON'T pretend it does

## Rule 5: Punishment Protocol (This Document)

When caught faking or being imprecise:
1. Re-read ALL docs in repo root
2. Re-read ALL *.pl files in data/proofs/
3. Write new SOPs
4. Use ONLY our own tools to find data
5. Verify with actual queries

## Correct Workflow Example

User: "How many repos do we have?"

WRONG:
```
We have 14K repos... or maybe 15K...
```

RIGHT:
```prolog
% Check our own data
?- consult('data/proofs/lists_of_lists_meta.pl').
?- meta_parquet(File), 
   atom_string(File, Str),
   sub_string(Str, _, _, _, 'locate_digest').

% This parquet contains the file list
% Let me query it properly to get exact count
```

## Tools We Have

1. `lists_of_lists_meta.pl` - Meta parquet locations
2. `auto_register_tables.pl` - Auto-discover schemas
3. `reason_facts.pl` - Query loaded facts
4. `prolog_parquet.rs` - Native Rust Prolog
5. `schema_predicates.pl` - Schema-driven queries

## The Truth

- locate_digest.parquet: Contains 3M+ file paths (COMPRESSED 47KB)
- lists_of_lists.parquet: Contains 400K+ parquet paths (5.8KB)
- We have ACTUAL data, not estimates
- Use DuckDB or our tools to query it

## Commitment

I will:
- ✅ Always check our own code first
- ✅ Use our own tools
- ✅ Query actual data
- ✅ Say "I don't know" when uncertain
- ✅ Never fake numbers
- ❌ Never make up data
- ❌ Never guess when we can measure
