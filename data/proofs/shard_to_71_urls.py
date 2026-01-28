#!/usr/bin/env python3
# shard_to_71_urls.py - Shard all data into 71 URLs with compressed payloads

import pandas as pd
import json
import base64
import zlib
from pathlib import Path

# Monster primes
MONSTER_PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71]

def hash_to_prime(entity_path: str) -> int:
    """Hash entity path to one of 71 primes"""
    h = hash(entity_path) % len(MONSTER_PRIMES)
    return MONSTER_PRIMES[h]

def compress_shard(entities: list) -> str:
    """Compress entities to base64 URL-safe string"""
    json_data = json.dumps(entities, separators=(',', ':'))
    compressed = zlib.compress(json_data.encode('utf-8'), level=9)
    b64 = base64.urlsafe_b64encode(compressed).decode('ascii')
    return b64

def main():
    print("🌌 Sharding all data into 71 URLs...\n")
    
    # Load Gödel lattice
    df = pd.read_parquet('generated/godel_lattice.parquet')
    print(f"Loaded {len(df)} entities\n")
    
    # Shard entities by prime
    shards = {p: [] for p in MONSTER_PRIMES}
    
    for _, row in df.iterrows():
        prime = hash_to_prime(row['entity_path'])
        shards[prime].append({
            'godel': int(row['godel']),
            'type': row['entity_type'],
            'path': row['entity_path'],
            'primes': row['primes']
        })
    
    # Generate URLs with compressed payloads
    urls = []
    for prime in MONSTER_PRIMES:
        entities = shards[prime]
        if not entities:
            continue
            
        # Compress shard
        payload = compress_shard(entities)
        
        # Generate URL
        url = f"https://github.com/Escaped-RDFa/namespace?prime={prime}&count={len(entities)}&data={payload[:100]}..."
        
        urls.append({
            'prime': prime,
            'entity_count': len(entities),
            'payload_size': len(payload),
            'compressed_ratio': len(json.dumps(entities)) / len(payload),
            'url': url,
            'full_payload': payload
        })
        
        print(f"Shard {prime:2d}: {len(entities):3d} entities, {len(payload):6d} bytes, {len(json.dumps(entities))/len(payload):.1f}x compression")
    
    # Save to parquet with URL column
    df_shards = pd.DataFrame(urls)
    df_shards.to_parquet('generated/71_shards.parquet')
    print(f"\n✅ Saved to generated/71_shards.parquet")
    
    # Save full URLs to JSON
    with open('generated/71_urls.json', 'w') as f:
        json.dump([{
            'prime': u['prime'],
            'entity_count': u['entity_count'],
            'url': f"https://github.com/Escaped-RDFa/namespace?prime={u['prime']}&count={u['entity_count']}&data={u['full_payload']}"
        } for u in urls], f, indent=2)
    print(f"✅ Saved to generated/71_urls.json")
    
    # Statistics
    total_entities = sum(u['entity_count'] for u in urls)
    total_compressed = sum(u['payload_size'] for u in urls)
    total_uncompressed = sum(len(json.dumps(shards[u['prime']])) for u in urls)
    
    print(f"\n📊 Statistics:")
    print(f"  Total entities: {total_entities}")
    print(f"  Total compressed: {total_compressed:,} bytes")
    print(f"  Total uncompressed: {total_uncompressed:,} bytes")
    print(f"  Compression ratio: {total_uncompressed/total_compressed:.1f}x")
    print(f"  Shards used: {len(urls)}/{len(MONSTER_PRIMES)}")
    
    print(f"\n✨ All data sharded into {len(urls)} URLs!")
    print(f"Each URL contains compressed entities for one prime.")

if __name__ == '__main__':
    main()
