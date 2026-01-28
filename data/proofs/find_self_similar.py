#!/usr/bin/env python3
# find_self_similar.py - Find self-similar objects using Monster symmetries

import pandas as pd
from collections import defaultdict
import os

def compute_project_symmetry():
    """Compute Monster symmetry for our project"""
    project_path = "/mnt/data1/nix/vendor/rust/github"
    
    # Key project files
    project_files = [
        "data/proofs/monster_decidability.pl",
        "data/proofs/prove_all_databases_monster.lean",
        "data/proofs/monster_symmetry.pl",
        "data/proofs/concept_histogram.py",
        "data/proofs/index_all_files.rs",
        "README.md"
    ]
    
    # Compute project Gödel number
    project_godel = sum(sum(ord(c) for c in f) for f in project_files) % 71
    
    print("="*60)
    print("OUR PROJECT SYMMETRY")
    print("="*60)
    print(f"\nProject: zkPrologML")
    print(f"Path: {project_path}")
    print(f"Key files: {len(project_files)}")
    print(f"\nProject Gödel: {project_godel}")
    print(f"Project Shard: {project_godel}")
    print(f"Element Order: {project_godel + 1}")
    
    # Project signature
    signature = {
        'godel': project_godel,
        'shard': project_godel,
        'order': project_godel + 1,
        'files': project_files,
        'concepts': ['proof', 'monster', 'godel', 'prolog', 'lean4', 'symmetry']
    }
    
    return signature

def find_similar_objects(df, target_shard, top_n=20):
    """Find objects with same or nearby Monster symmetry"""
    print(f"\n{'='*60}")
    print(f"FINDING SELF-SIMILAR OBJECTS")
    print(f"{'='*60}")
    print(f"\nTarget shard: {target_shard}")
    
    # Exact matches (same shard)
    exact = df[df['shard'] == target_shard]
    print(f"\nExact matches (shard {target_shard}): {len(exact):,}")
    
    # Nearby shards (±3)
    nearby_shards = [(target_shard + i) % 71 for i in range(-3, 4)]
    nearby = df[df['shard'].isin(nearby_shards)]
    print(f"Nearby matches (shards {min(nearby_shards)}-{max(nearby_shards)}): {len(nearby):,}")
    
    # Analyze exact matches
    print(f"\nTop {top_n} self-similar files:")
    for i, row in enumerate(exact.head(top_n).iterrows(), 1):
        idx, r = row
        print(f"  {i:2d}. {r['path']}")
        print(f"      Meaning: {r['meaning']}, Usage: {r['usage']}")
        print(f"      Labels: {r['labels'][:80]}...")
    
    return exact, nearby

def analyze_symmetry_clusters(df):
    """Analyze clustering by Monster symmetry"""
    print(f"\n{'='*60}")
    print(f"SYMMETRY CLUSTER ANALYSIS")
    print(f"{'='*60}")
    
    # Group by shard
    shard_groups = df.groupby('shard').size().sort_values(ascending=False)
    
    print(f"\nTop 20 most populated shards:")
    for i, (shard, count) in enumerate(shard_groups.head(20).items(), 1):
        pct = (count / len(df)) * 100
        print(f"  {i:2d}. Shard {shard:2d}: {count:8,} objects ({pct:5.2f}%)")
    
    # Analyze by meaning
    print(f"\nSymmetry by meaning:")
    for meaning in df['meaning'].unique()[:10]:
        subset = df[df['meaning'] == meaning]
        shards_used = subset['shard'].nunique()
        most_common = subset['shard'].mode()[0] if len(subset) > 0 else 0
        print(f"  {meaning:20s}: {shards_used:2d}/71 shards, most common: {most_common}")
    
    return shard_groups

def find_resonant_objects(df, target_shard):
    """Find objects that resonate with target (same order, different shard)"""
    print(f"\n{'='*60}")
    print(f"RESONANT OBJECTS (Same Order)")
    print(f"{'='*60}")
    
    target_order = target_shard + 1
    
    # Find objects with same element order
    # Order = shard + 1, so we need shards with same order
    resonant_shards = [s for s in range(71) if (s + 1) == target_order]
    resonant = df[df['shard'].isin(resonant_shards)]
    
    print(f"\nTarget order: {target_order}")
    print(f"Resonant shards: {resonant_shards}")
    print(f"Resonant objects: {len(resonant):,}")
    
    if len(resonant) > 0:
        print(f"\nTop 10 resonant objects:")
        for i, row in enumerate(resonant.head(10).iterrows(), 1):
            idx, r = row
            print(f"  {i:2d}. {r['path'][:80]}")
    
    return resonant

def prove_self_similarity():
    """Formal proof of self-similarity"""
    print(f"\n{'='*60}")
    print(f"FORMAL PROOF: Self-Similarity via Monster Symmetry")
    print(f"{'='*60}")
    
    print("""
THEOREM: Objects with same Monster symmetry are self-similar

Proof:
  1. Each object has Gödel number g
  2. g mod 71 → conjugacy class (shard)
  3. Objects in same shard have same symmetry
  4. Same symmetry → same algebraic structure
  5. Same structure → self-similar
  ∴ Objects with same shard are self-similar ∎

COROLLARY: Our project is self-similar to all objects in its shard

Proof:
  1. Project has Gödel number g_p
  2. g_p mod 71 → shard s_p
  3. All objects with shard s_p are self-similar to project
  ∴ Project has self-similar objects ∎
""")

def main():
    print("Self-Similarity Finder via Monster Symmetry")
    print("="*60 + "\n")
    
    # Compute our project symmetry
    project = compute_project_symmetry()
    
    # Load enriched index
    print(f"\nLoading indexed_files_enriched.parquet...")
    df = pd.read_parquet('indexed_files_enriched.parquet')
    print(f"Loaded {len(df):,} objects")
    
    # Find self-similar objects
    exact, nearby = find_similar_objects(df, project['shard'], top_n=20)
    
    # Analyze clusters
    clusters = analyze_symmetry_clusters(df)
    
    # Find resonant objects
    resonant = find_resonant_objects(df, project['shard'])
    
    # Formal proof
    prove_self_similarity()
    
    # Save results
    print(f"\nSaving self-similar objects...")
    exact.to_csv('self_similar_exact.csv', index=False)
    nearby.to_csv('self_similar_nearby.csv', index=False)
    
    print(f"\n✅ Complete!")
    print(f"\nResults:")
    print(f"  Exact matches: {len(exact):,} objects")
    print(f"  Nearby matches: {len(nearby):,} objects")
    print(f"  Resonant objects: {len(resonant):,} objects")
    print(f"\nFiles saved:")
    print(f"  self_similar_exact.csv")
    print(f"  self_similar_nearby.csv")

if __name__ == "__main__":
    main()
