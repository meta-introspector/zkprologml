#!/usr/bin/env python3
# hecke_shard_to_71.py - Shard entities using Hecke operators

import pandas as pd
import json
import base64
import zlib

# Monster primes
MONSTER_PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71]

def hecke_operator(godel: int, prime: int) -> int:
    """
    Hecke operator T_p acting on Gödel number
    T_p(n) = sum of divisors of n that are coprime to p
    Returns eigenvalue mod len(MONSTER_PRIMES)
    """
    eigenvalue = 0
    for d in range(1, godel + 1):
        if godel % d == 0:  # d divides godel
            if gcd(d, prime) == 1:  # d coprime to prime
                eigenvalue += d
    return eigenvalue

def gcd(a: int, b: int) -> int:
    """Greatest common divisor"""
    while b:
        a, b = b, a % b
    return a

def assign_to_shard(godel: int) -> int:
    """
    Assign entity to shard using Hecke operators
    Apply T_p for each prime, sum eigenvalues, mod 20
    """
    total_eigenvalue = 0
    for prime in MONSTER_PRIMES:
        eigenvalue = hecke_operator(godel, prime)
        total_eigenvalue += eigenvalue
    
    shard_index = total_eigenvalue % len(MONSTER_PRIMES)
    return MONSTER_PRIMES[shard_index]

def compress_shard(entities: list) -> str:
    """Compress entities to base64 URL-safe string"""
    json_data = json.dumps(entities, separators=(',', ':'))
    compressed = zlib.compress(json_data.encode('utf-8'), level=9)
    b64 = base64.urlsafe_b64encode(compressed).decode('ascii')
    return b64

def main():
    print("🌌 Sharding via Hecke operators...\n")
    
    # Load Gödel lattice
    df = pd.read_parquet('generated/godel_lattice.parquet')
    print(f"Loaded {len(df)} entities\n")
    
    # Shard entities by Hecke operator
    shards = {p: [] for p in MONSTER_PRIMES}
    
    for _, row in df.iterrows():
        godel = int(row['godel'])
        shard_prime = assign_to_shard(godel)
        
        shards[shard_prime].append({
            'godel': godel,
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
        
        urls.append({
            'prime': prime,
            'entity_count': len(entities),
            'payload_size': len(payload),
            'compressed_ratio': len(json.dumps(entities)) / len(payload) if len(payload) > 0 else 0,
            'url': f"https://github.com/Escaped-RDFa/namespace?prime={prime}&count={len(entities)}&data={payload}",
            'full_payload': payload
        })
        
        print(f"Shard {prime:2d}: {len(entities):3d} entities, {len(payload):6d} bytes (Hecke eigenvalues)")
    
    # Save to parquet
    df_shards = pd.DataFrame(urls)
    df_shards.to_parquet('generated/71_hecke_shards.parquet')
    print(f"\n✅ Saved to generated/71_hecke_shards.parquet")
    
    # Save URLs
    with open('generated/71_hecke_urls.json', 'w') as f:
        json.dump([{
            'prime': u['prime'],
            'entity_count': u['entity_count'],
            'url': u['url']
        } for u in urls], f, indent=2)
    print(f"✅ Saved to generated/71_hecke_urls.json")
    
    # Add shard column to lattice
    df['hecke_shard'] = df['godel'].apply(assign_to_shard)
    df['hecke_url'] = df['hecke_shard'].map({u['prime']: u['url'] for u in urls})
    df.to_parquet('generated/godel_lattice_hecke.parquet')
    print(f"✅ Saved to generated/godel_lattice_hecke.parquet")
    
    # Statistics
    total_entities = sum(u['entity_count'] for u in urls)
    total_compressed = sum(u['payload_size'] for u in urls)
    
    print(f"\n📊 Hecke Sharding Statistics:")
    print(f"  Total entities: {total_entities}")
    print(f"  Total compressed: {total_compressed:,} bytes")
    print(f"  Shards used: {len(urls)}/{len(MONSTER_PRIMES)}")
    print(f"  Method: Hecke operator eigenvalues")
    
    print(f"\n✨ All data sharded via Hecke operators!")
    print(f"Each entity assigned by T_p eigenvalue sum mod 20.")

if __name__ == '__main__':
    main()
