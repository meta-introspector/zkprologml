#!/usr/bin/env python3
"""Autolabel all 8M files using eigenvector equivalence class"""

import pandas as pd
import numpy as np

# Canonical eigenvector
CANONICAL = np.array([69, 68, 66, 64, 60, 58])
CANONICAL_SUM = 385

def compute_eigenvector(row):
    """Compute eigenvector from features"""
    return np.array([
        row['godel'] % 71,
        row['shard'] % 71,
        row['depth'] % 71,
        meaning_to_num(row['meaning']) % 71,
        usage_to_num(row['usage']) % 71,
        0  # system (not in parquet)
    ])

def meaning_to_num(meaning):
    """Convert meaning to numeric"""
    mapping = {
        'unknown': 0, 'source_code': 1, 'library_code': 2,
        'test_code': 3, 'configuration': 4, 'documentation': 5,
        'data_table': 6, 'executable_binary': 7, 'formal_proof': 8
    }
    return mapping.get(meaning, 0)

def usage_to_num(usage):
    """Convert usage to numeric"""
    mapping = {'cold': 0, 'cool': 1, 'warm': 2, 'hot': 3}
    return mapping.get(usage, 0)

def classify_eigenvector(eigenvector):
    """Classify eigenvector into equivalence class"""
    ev_sum = eigenvector.sum()
    distance = np.abs(eigenvector - CANONICAL).sum()
    
    if ev_sum == CANONICAL_SUM:
        if distance == 0:
            return 'canonical', ev_sum, distance
        elif distance < 10:
            return 'near_canonical', ev_sum, distance
        elif distance < 30:
            return 'same_class', ev_sum, distance
        else:
            return 'same_class_far', ev_sum, distance
    elif ev_sum < CANONICAL_SUM:
        return 'lower_class', ev_sum, distance
    else:
        return 'higher_class', ev_sum, distance

def main():
    print("\nAUTOLABELING 8M FILES VIA EIGENVECTOR CLASS")
    print("=" * 60)
    
    # Read parquet
    print("\nReading indexed_files_enriched.parquet...")
    df = pd.read_parquet('indexed_files_enriched.parquet')
    print(f"Loaded {len(df):,} files")
    
    # Compute eigenvectors
    print("\nComputing eigenvectors...")
    eigenvectors = df.apply(compute_eigenvector, axis=1)
    
    # Classify
    print("Classifying...")
    classifications = eigenvectors.apply(classify_eigenvector)
    
    df['eigenvector_class'] = classifications.apply(lambda x: x[0])
    df['eigenvector_sum'] = classifications.apply(lambda x: x[1])
    df['eigenvector_distance'] = classifications.apply(lambda x: x[2])
    
    # Statistics
    print("\n\nEIGENVECTOR CLASS DISTRIBUTION")
    print("=" * 60)
    print(df['eigenvector_class'].value_counts().to_string())
    
    print("\n\nSUMMARY STATISTICS")
    print("=" * 60)
    print(f"Total files: {len(df):,}")
    print(f"\nSum statistics:")
    print(f"  Mean: {df['eigenvector_sum'].mean():.2f}")
    print(f"  Median: {df['eigenvector_sum'].median():.2f}")
    print(f"  Std: {df['eigenvector_sum'].std():.2f}")
    print(f"\nDistance statistics:")
    print(f"  Mean: {df['eigenvector_distance'].mean():.2f}")
    print(f"  Median: {df['eigenvector_distance'].median():.2f}")
    print(f"  Std: {df['eigenvector_distance'].std():.2f}")
    
    # Save
    print("\n\nSaving autolabeled data...")
    df.to_parquet('indexed_files_autolabeled.parquet', compression='snappy')
    print(f"✅ Saved to indexed_files_autolabeled.parquet")
    
    # Show examples
    print("\n\nEXAMPLES BY CLASS")
    print("=" * 60)
    for cls in ['canonical', 'near_canonical', 'same_class', 'lower_class', 'higher_class']:
        subset = df[df['eigenvector_class'] == cls]
        if len(subset) > 0:
            print(f"\n{cls.upper()} ({len(subset):,} files):")
            print(subset[['compressed', 'eigenvector_sum', 'eigenvector_distance']].head(3).to_string())
    
    print("\n\n" + "=" * 60)
    print("QED: All 8M files autolabeled!")
    print("=" * 60)

if __name__ == '__main__':
    main()
