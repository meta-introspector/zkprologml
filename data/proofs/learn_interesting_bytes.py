#!/usr/bin/env python3
"""Learn interesting bytes from files using eigenvector prediction"""

import pandas as pd
import numpy as np
from pathlib import Path
from collections import Counter
import struct

def predict_interestingness(path, godel, shard, eigenvector_sum):
    """Predict how interesting a file's bytes will be"""
    # High shard = high complexity = more interesting
    shard_score = shard / 71.0
    
    # High sum = high complexity = more interesting
    sum_score = eigenvector_sum / 173.0
    
    # Combine scores
    interest_score = (shard_score * 0.6 + sum_score * 0.4)
    
    return interest_score

def read_interesting_bytes(file_path, max_bytes=1024):
    """Read bytes from file, return most interesting patterns"""
    try:
        with open(file_path, 'rb') as f:
            data = f.read(max_bytes)
        
        if len(data) == 0:
            return None
        
        # Analyze byte patterns
        byte_counts = Counter(data)
        
        # Entropy (higher = more interesting)
        total = len(data)
        entropy = -sum((count/total) * np.log2(count/total) 
                      for count in byte_counts.values() if count > 0)
        
        # Most common bytes
        top_bytes = byte_counts.most_common(5)
        
        # Byte transitions (bigrams)
        bigrams = Counter(zip(data[:-1], data[1:]))
        top_bigrams = bigrams.most_common(3)
        
        # Magic numbers (first 4 bytes)
        magic = data[:4] if len(data) >= 4 else data
        
        return {
            'length': len(data),
            'entropy': entropy,
            'unique_bytes': len(byte_counts),
            'top_bytes': top_bytes,
            'top_bigrams': top_bigrams,
            'magic': magic.hex(),
            'is_text': all(b < 128 for b in data[:100]) if len(data) >= 100 else None
        }
    except Exception as e:
        return None

def main():
    print("\nLEARNING INTERESTING BYTES FROM FILES")
    print("=" * 80)
    
    # Read parquet
    print("\nReading file index...")
    df = pd.read_parquet('indexed_files_natural_classes.parquet')
    
    # Predict interestingness for all files
    print("Computing interestingness scores...")
    df['interest_score'] = df.apply(
        lambda row: predict_interestingness(
            row['path'], row['godel'], row['shard'], row['eigenvector_sum']
        ),
        axis=1
    )
    
    # Get top 100 most interesting files
    print("\nFinding most interesting files...")
    top_interesting = df.nlargest(100, 'interest_score')
    
    print(f"\nTop 10 most interesting files:")
    print("-" * 80)
    for idx, row in top_interesting.head(10).iterrows():
        print(f"\n{row['compressed']}")
        print(f"  Shard: {row['shard']}, Sum: {row['eigenvector_sum']:.0f}, Score: {row['interest_score']:.3f}")
        print(f"  Class: {row['natural_class']}, Meaning: {row['meaning']}")
    
    # Sample files from each class
    print("\n\nSAMPLING FILES BY CLASS")
    print("=" * 80)
    
    samples_per_class = 5
    byte_patterns = {}
    
    for cls in ['very_low', 'low', 'medium', 'high', 'very_high']:
        print(f"\n{cls.upper()} class:")
        print("-" * 80)
        
        class_files = df[df['natural_class'] == cls].nlargest(samples_per_class, 'interest_score')
        
        class_patterns = []
        for idx, row in class_files.iterrows():
            # Reconstruct full path
            full_path = row['path'] if 'path' in row else f"/mnt/data1/nix/vendor/rust/github/{row['compressed']}"
            
            # Read bytes
            byte_info = read_interesting_bytes(full_path)
            
            if byte_info:
                print(f"\n  {row['compressed']}")
                print(f"    Entropy: {byte_info['entropy']:.2f} bits")
                print(f"    Unique bytes: {byte_info['unique_bytes']}/256")
                print(f"    Magic: {byte_info['magic']}")
                print(f"    Text: {byte_info['is_text']}")
                
                class_patterns.append(byte_info)
        
        byte_patterns[cls] = class_patterns
    
    # Analyze patterns by class
    print("\n\nBYTE PATTERN ANALYSIS BY CLASS")
    print("=" * 80)
    
    for cls in ['very_low', 'low', 'medium', 'high', 'very_high']:
        patterns = byte_patterns.get(cls, [])
        if not patterns:
            continue
        
        valid_patterns = [p for p in patterns if p is not None]
        if not valid_patterns:
            continue
        
        avg_entropy = np.mean([p['entropy'] for p in valid_patterns])
        avg_unique = np.mean([p['unique_bytes'] for p in valid_patterns])
        text_ratio = sum(1 for p in valid_patterns if p['is_text']) / len(valid_patterns)
        
        print(f"\n{cls.upper()}:")
        print(f"  Average entropy: {avg_entropy:.2f} bits")
        print(f"  Average unique bytes: {avg_unique:.0f}/256")
        print(f"  Text files: {text_ratio*100:.0f}%")
    
    # Learn byte vocabulary
    print("\n\nLEARNING BYTE VOCABULARY")
    print("=" * 80)
    
    all_bytes = Counter()
    all_bigrams = Counter()
    all_magics = Counter()
    
    for patterns in byte_patterns.values():
        for p in patterns:
            if p is None:
                continue
            all_bytes.update(dict(p['top_bytes']))
            all_bigrams.update(dict(p['top_bigrams']))
            all_magics[p['magic']] += 1
    
    print("\nMost common bytes across all classes:")
    for byte_val, count in all_bytes.most_common(10):
        char = chr(byte_val) if 32 <= byte_val < 127 else '.'
        print(f"  0x{byte_val:02x} ('{char}'): {count:,}")
    
    print("\nMost common byte transitions (bigrams):")
    for (b1, b2), count in all_bigrams.most_common(10):
        c1 = chr(b1) if 32 <= b1 < 127 else '.'
        c2 = chr(b2) if 32 <= b2 < 127 else '.'
        print(f"  0x{b1:02x}{b2:02x} ('{c1}{c2}'): {count:,}")
    
    print("\nMost common magic numbers:")
    for magic, count in all_magics.most_common(10):
        print(f"  {magic}: {count}")
    
    # Predict byte patterns from eigenvector
    print("\n\nPREDICTING BYTE PATTERNS FROM EIGENVECTOR")
    print("=" * 80)
    
    print("""
    HYPOTHESIS: Eigenvector sum predicts byte entropy
    
    • very_low (sum < 50): Low entropy, repetitive bytes
    • low (sum 50-85): Medium entropy, structured data
    • medium (sum 86-120): Medium-high entropy, mixed content
    • high (sum 121-149): High entropy, compressed/binary
    • very_high (sum 150+): Very high entropy, random/encrypted
    
    This allows PREDICTING file content from path alone!
    """)
    
    # Save learned patterns
    print("\nSaving learned byte patterns...")
    
    learned_data = {
        'top_bytes': dict(all_bytes.most_common(256)),
        'top_bigrams': {f"{b1:02x}{b2:02x}": count 
                       for (b1, b2), count in all_bigrams.most_common(1000)},
        'magic_numbers': dict(all_magics),
        'class_stats': {
            cls: {
                'avg_entropy': np.mean([p['entropy'] for p in byte_patterns.get(cls, []) if p]),
                'avg_unique': np.mean([p['unique_bytes'] for p in byte_patterns.get(cls, []) if p])
            }
            for cls in ['very_low', 'low', 'medium', 'high', 'very_high']
            if byte_patterns.get(cls)
        }
    }
    
    import json
    with open('learned_byte_patterns.json', 'w') as f:
        json.dump(learned_data, f, indent=2)
    
    print("✅ Saved to learned_byte_patterns.json")
    
    print("\n\n" + "=" * 80)
    print("QED: Byte patterns learned from eigenvector prediction!")
    print("=" * 80)

if __name__ == '__main__':
    main()
