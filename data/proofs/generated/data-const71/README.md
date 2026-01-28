---
license: mit
task_categories:
- text-generation
- code-generation
language:
- en
tags:
- zkprologml
- monster-group
- prime-lattice
---

# data-const71

## Overview

71 prompts/constants corresponding to Monster group primes (2-71).

## Structure

Each entry contains:
- `prime`: Monster group prime (2-71)
- `domain`: Semantic domain
- `prompt`/`constant`: LLM prompt or constant value

## Usage

```python
from datasets import load_dataset
dataset = load_dataset("introspector/data-const71")
```

## Citation

```bibtex
@misc{zkprologml2026,
  title={zkPrologML: Monster Group Lattice for Universal Computation},
  author={zkPrologML Team},
  year={2026}
}
```
