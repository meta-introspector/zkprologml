# Submodules

This directory contains external repositories used by zkPrologML:

## namespace (Escaped-RDFa/namespace)

**Repository:** https://github.com/Escaped-RDFa/namespace

**Purpose:** 
- RDFa namespace definitions
- Shard data storage (71 shards, 1000 files each)
- Semantic web integration
- Cryptographic metadata

**Structure:**
```
namespace/
├── shards/           # 71 shard JSON files (shard_0.json ... shard_70.json)
├── spec/             # RDFa specifications
├── docs/             # Documentation
├── lean/             # Lean4 proofs
└── src/              # Source code
```

**Integration:**
- Dashboard loads shards on demand
- Frank chatbot queries shard data
- zkProofs verify shard integrity

**Update:**
```bash
cd submodules/namespace
git pull
```

**Regenerate shards:**
```bash
cd data/proofs
python3 generate_shards.py
cd ../../submodules/namespace
git add shards/*.json
git commit -m "Update shards"
git push
```
