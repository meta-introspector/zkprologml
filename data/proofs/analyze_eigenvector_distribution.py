#!/usr/bin/env python3
"""Analyze eigenvector distribution and find natural classes"""

import pandas as pd
import numpy as np

def compute_eigenvector(row):
    """Compute eigenvector from features"""
    return np.array([
        row['godel'] % 71,
        row['shard'] % 71,
        row['depth'] % 71,
        meaning_to_num(row['meaning']) % 71,
        usage_to_num(row['usage']) % 71,
        0  # system
    ])

def meaning_to_num(meaning):
    mapping = {
        'unknown': 0, 'source_code': 1, 'library_code': 2,
        'test_code': 3, 'configuration': 4, 'documentation': 5,
        'data_table': 6, 'executable_binary': 7, 'formal_proof': 8
    }
    return mapping.get(meaning, 0)

def usage_to_num(usage):
    mapping = {'cold': 0, 'cool': 1, 'warm': 2, 'hot': 3}
    return mapping.get(usage, 0)

def main():
    print("\nANALYZING EIGENVECTOR DISTRIBUTION")
    print("=" * 60)
    
    # Read
    print("\nReading parquet...")
    df = pd.read_parquet('indexed_files_enriched.parquet')
    print(f"Loaded {len(df):,} files")
    
    # Compute eigenvectors
    print("\nComputing eigenvectors...")
    eigenvectors = df.apply(compute_eigenvector, axis=1)
    
    # Convert to matrix
    ev_matrix = np.vstack(eigenvectors.values)
    
    # Compute sums
    ev_sums = ev_matrix.sum(axis=1)
    
    # Find natural clusters
    print("\n\nEIGENVECTOR SUM DISTRIBUTION")
    print("=" * 60)
    
    percentiles = [0, 1, 5, 10, 25, 50, 75, 90, 95, 99, 100]
    for p in percentiles:
        val = np.percentile(ev_sums, p)
        print(f"  {p:3d}th percentile: {val:.0f}")
    
    # Find most common sums
    print("\n\nMOST COMMON EIGENVECTOR SUMS")
    print("=" * 60)
    unique, counts = np.unique(ev_sums, return_counts=True)
    top_indices = np.argsort(counts)[-10:][::-1]
    
    for idx in top_indices:
        s = unique[idx]
        c = counts[idx]
        print(f"  Sum {s:3.0f}: {c:,} files ({c/len(df)*100:.2f}%)")
    
    # Find actual canonical (most common)
    actual_canonical_sum = unique[np.argmax(counts)]
    print(f"\n✅ Actual canonical sum: {actual_canonical_sum:.0f}")
    
    # Find files with this sum
    canonical_mask = ev_sums == actual_canonical_sum
    canonical_files = df[canonical_mask]
    
    print(f"✅ Files with canonical sum: {len(canonical_files):,}")
    
    # Compute mean eigenvector
    mean_eigenvector = ev_matrix.mean(axis=0)
    print(f"\n\nMEAN EIGENVECTOR (from data)")
    print("=" * 60)
    print(f"  {mean_eigenvector.astype(int)}")
    print(f"  Sum: {mean_eigenvector.sum():.0f}")
    
    # Compute median eigenvector
    median_eigenvector = np.median(ev_matrix, axis=0)
    print(f"\n\nMEDIAN EIGENVECTOR (from data)")
    print("=" * 60)
    print(f"  {median_eigenvector.astype(int)}")
    print(f"  Sum: {median_eigenvector.sum():.0f}")
    
    # Compare with theoretical
    theoretical = np.array([69, 68, 66, 64, 60, 58])
    print(f"\n\nTHEORETICAL EIGENVECTOR (from convergence)")
    print("=" * 60)
    print(f"  {theoretical}")
    print(f"  Sum: {theoretical.sum()}")
    
    # Classify based on actual distribution
    print("\n\nNATURAL CLASSES (based on percentiles)")
    print("=" * 60)
    
    p25 = np.percentile(ev_sums, 25)
    p50 = np.percentile(ev_sums, 50)
    p75 = np.percentile(ev_sums, 75)
    p95 = np.percentile(ev_sums, 95)
    
    df['natural_class'] = pd.cut(
        ev_sums,
        bins=[0, p25, p50, p75, p95, 1000],
        labels=['very_low', 'low', 'medium', 'high', 'very_high']
    )
    
    print(df['natural_class'].value_counts().to_string())
    
    # Save with natural classes
    df['eigenvector_sum'] = ev_sums
    df.to_parquet('indexed_files_natural_classes.parquet', compression='snappy')
    print(f"\n✅ Saved to indexed_files_natural_classes.parquet")
    
    print("\n\n" + "=" * 60)
    print("QED: Natural eigenvector classes discovered!")
    print("=" * 60)

if __name__ == '__main__':
    main()
