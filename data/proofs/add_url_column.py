#!/usr/bin/env python3
# add_url_column.py - Add shard URL column to godel_lattice.parquet

import pandas as pd
import json

print("📦 Adding URL column to Gödel lattice...\n")

# Load original lattice
df = pd.read_parquet('generated/godel_lattice.parquet')
print(f"Loaded {len(df)} entities")

# Load shard URLs
with open('generated/71_urls.json', 'r') as f:
    urls = json.load(f)

# Create prime -> URL mapping
prime_to_url = {u['prime']: u['url'] for u in urls}

# Hash function (same as shard_to_71_urls.py)
MONSTER_PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71]

def hash_to_prime(entity_path: str) -> int:
    h = hash(entity_path) % len(MONSTER_PRIMES)
    return MONSTER_PRIMES[h]

# Add shard_prime and shard_url columns
df['shard_prime'] = df['entity_path'].apply(hash_to_prime)
df['shard_url'] = df['shard_prime'].map(prime_to_url)

# Save updated parquet
df.to_parquet('generated/godel_lattice_with_urls.parquet')
print(f"✅ Saved to generated/godel_lattice_with_urls.parquet")

# Show sample
print(f"\n📊 Sample with URLs:")
print(df[['godel', 'entity_type', 'entity_path', 'shard_prime', 'shard_url']].head(3).to_string())

print(f"\n✨ Every entity now has its shard URL!")
print(f"Query any entity to get its compressed shard URL.")
