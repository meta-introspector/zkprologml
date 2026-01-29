#!/usr/bin/env python3
"""Generate shard JSON files for GitHub namespace repo"""

import pandas as pd
import json
from pathlib import Path

# Load parquet
print("Loading parquet...")
df = pd.read_parquet('/mnt/data1/nix/vendor/rust/github/data/proofs/indexed_files_natural_classes.parquet')

print(f"Total rows: {len(df)}")

# Create output directory
output_dir = Path('/tmp/namespace/shards')
output_dir.mkdir(exist_ok=True)

# Generate shard files (0-70)
for shard_num in range(71):
    shard_df = df[df['shard'] == shard_num]
    
    if len(shard_df) == 0:
        print(f"Shard {shard_num}: empty, skipping")
        continue
    
    # Convert to list of dicts (first 1000 rows per shard for size)
    records = shard_df.head(1000).to_dict('records')
    
    # Write JSON
    output_file = output_dir / f'shard_{shard_num}.json'
    with open(output_file, 'w') as f:
        json.dump(records, f, indent=2)
    
    print(f"Shard {shard_num}: {len(records)} files → {output_file}")

print(f"\n✅ Generated {len(list(output_dir.glob('*.json')))} shard files")
