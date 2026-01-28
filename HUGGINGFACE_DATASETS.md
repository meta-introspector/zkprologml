# HuggingFace Datasets Integration

## Datasets

We have published 71 zkPrologML prompts and constants to HuggingFace:

### 1. data-moonshine
- **URL**: https://huggingface.co/datasets/introspector/data-moonshine
- **Content**: 71 LLM prompts for zkPrologML
- **Format**: JSONL
- **Location**: `datasets/data-moonshine/` (git submodule)

### 2. data-const71
- **URL**: https://huggingface.co/datasets/introspector/data-const71
- **Content**: 71 constants for Monster primes
- **Format**: JSONL
- **Location**: `datasets/data-const71/` (git submodule)

## Setup

### Clone with submodules
```bash
git clone --recursive https://github.com/meta-introspector/zkprologml
```

### Update submodules
```bash
git submodule update --init --recursive
```

### Access HuggingFace datasets
```bash
# Load SSH key
source ~/.agentrc

# Pull latest
cd datasets/data-moonshine && git pull origin main
cd datasets/data-const71 && git pull origin main
```

## Usage

### Python
```python
from datasets import load_dataset

# Load moonshine prompts
moonshine = load_dataset("introspector/data-moonshine")

# Load const71 constants
const71 = load_dataset("introspector/data-const71")
```

### Rust
```rust
// datasets/data-moonshine/prompts.jsonl
// datasets/data-const71/constants.jsonl
```

## Structure

Each dataset entry contains:
- `prime`: Monster group prime (2-71)
- `domain`: Semantic domain
- `prompt`/`constant`: Content
- `dataset`: Dataset name

## Regenerate

```bash
cd data/proofs
./generate_clean_datasets

# Push updates
source ~/.agentrc
cd generated/data-moonshine && git add . && git commit -m "Update" && git push
cd generated/data-const71 && git add . && git commit -m "Update" && git push
```

## Links

- data-moonshine: https://huggingface.co/datasets/introspector/data-moonshine
- data-const71: https://huggingface.co/datasets/introspector/data-const71
- Main repo: https://github.com/meta-introspector/zkprologml
