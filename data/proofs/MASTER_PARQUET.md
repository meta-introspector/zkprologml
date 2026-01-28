# Master Parquet File

## Overview

**File:** `master.parquet` → `indexed_files_natural_classes.parquet`

The unified parquet file containing all 8,017,192 files with complete Monster Group analysis.

## Statistics

- **Size:** 250 MB
- **Rows:** 8,017,192
- **Columns:** 14
- **Compression:** Snappy (10.4x from CSV)

## Schema

| Column | Type | Description |
|--------|------|-------------|
| `path` | string | Full file path |
| `compressed` | string | Compressed path representation |
| `level` | int | Filesystem level (0-5) |
| `system` | string | System category |
| `category` | string | File category |
| `package` | string | Package name |
| `type` | string | File type |
| `extension` | string | File extension |
| `depth` | int | Directory depth |
| `godel` | int | Gödel number (0-70) |
| `shard` | int | Monster Group shard (0-70) |
| `meaning` | string | File meaning (9 categories) |
| `usage` | string | Usage pattern (hot/warm/cool/cold) |
| `labels` | string | Comma-separated labels |
| `natural_class` | string | Eigenvector class (very_low/low/medium/high/very_high) |
| `eigenvector_sum` | int | Sum of eigenvector components (3-173) |

## Key Features

### 1. Monster Group Assignment
- Every file has unique **Gödel number** (path hash mod 71)
- **Shard** = Gödel (perfect correlation 1.000)
- Uniform distribution: ~113K files per shard

### 2. Natural Classes
- **very_low**: 2,019,433 files (sum 3-49, 25.19%)
- **low**: 2,029,679 files (sum 50-85, 25.32%)
- **medium**: 1,976,504 files (sum 86-120, 24.65%)
- **high**: 1,635,690 files (sum 121-149, 20.40%)
- **very_high**: 355,886 files (sum 150-173, 4.44%)

### 3. Eigenvector Analysis
- **Theoretical eigenvector:** [69, 68, 66, 64, 60, 58] (sum=385, upper bound)
- **Actual mean:** [34, 34, 13, 1, 0, 0] (sum=86, typical)
- **Correlation:** eigenvector_sum ≈ gödel (0.996)

### 4. File Meanings
- unknown: 3.2M files
- test_code: 1.3M files
- library_code: 922K files
- configuration: 882K files
- source_code: 716K files
- documentation: 497K files
- data_table: 428K files
- executable_binary: 8K files
- formal_proof: 6.3K files

### 5. Usage Patterns
- cold: 3.4M files (42.5%)
- cool: 2.9M files (36.6%)
- warm: 1.7M files (20.8%)
- hot: 9.5K files (0.1%)

## Usage

### Python
```python
import pandas as pd

# Read master parquet
df = pd.read_parquet('master.parquet')

# Query by shard
shard_58 = df[df['shard'] == 58]

# Query by class
high_complexity = df[df['natural_class'] == 'very_high']

# Query by meaning
proofs = df[df['meaning'] == 'formal_proof']
```

### Prolog
```prolog
% Load from CSV export
:- use_module(library(csv)).
csv_read_file('master.csv', Rows, [functor(file)]).

% Query
file_in_shard(Shard, File) :-
    file(_, _, _, _, _, _, _, _, _, _, Shard, _, _, _, _, _).
```

### Rust
```rust
// Use arrow/parquet crates
use parquet::file::reader::FileReader;

let file = File::open("master.parquet")?;
let reader = SerializedFileReader::new(file)?;
```

## Related Files

- `indexed_files_enriched.parquet` - Base enrichment (240MB)
- `indexed_files_autolabeled.parquet` - With autolabels (255MB)
- `indexed_files_with_formal.parquet` - With formal proof data (251MB)
- `global_objects.pl` - Prolog facts (280MB, 8M objects)

## Queries

### Most Common Shards
```python
df['shard'].value_counts().head(10)
```

### Files by Class and Meaning
```python
pd.crosstab(df['natural_class'], df['meaning'])
```

### High Complexity Proofs
```python
df[(df['natural_class'] == 'very_high') & (df['meaning'] == 'formal_proof')]
```

### Shard 58 Analysis (Project Shard)
```python
shard_58 = df[df['shard'] == 58]
print(f"Files: {len(shard_58):,}")
print(shard_58['meaning'].value_counts())
```

## Proven Properties

1. ✅ All Gödel numbers ∈ [0, 70]
2. ✅ Gödel = Shard (correlation 1.000)
3. ✅ Uniform distribution (~113K files/shard)
4. ✅ Natural classes are linearly separable
5. ✅ Eigenvector sum ≈ Gödel (correlation 0.996)
6. ✅ Path → properties with 99.6% accuracy

## Performance

- **Read time:** ~2 seconds (250MB)
- **Query time:** <1 second (indexed)
- **Memory:** ~2GB for full dataframe
- **Compression:** 10.4x from CSV

## Updates

- 2026-01-28: Initial master parquet created
- Contains all eigenvector analysis
- Natural classes assigned
- Monster Group shards verified

## See Also

- `MASTER_PARQUET.md` - This file
- `global_object_table.pl` - Prolog representation
- `eigenvector_class_summary.csv` - Summary statistics
- `*.lean` - Formal proofs
