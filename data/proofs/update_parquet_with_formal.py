#!/usr/bin/env python3
"""Update parquet with parsed formal file data"""

import pandas as pd
import json
from pathlib import Path

def main():
    print("\nUPDATING PARQUET WITH PARSED DATA")
    print("=" * 80)
    
    # Read existing parquet
    print("\nReading indexed_files_natural_classes.parquet...")
    df = pd.read_parquet('indexed_files_natural_classes.parquet')
    print(f"Loaded {len(df):,} files")
    
    # Read parsed data
    print("\nReading parsed_formal_files.json...")
    with open('parsed_formal_files.json', 'r') as f:
        parsed = json.load(f)
    
    # Initialize new columns
    df['has_theorems'] = False
    df['num_theorems'] = 0
    df['num_definitions'] = 0
    df['num_lemmas'] = 0
    df['num_functions'] = 0
    df['num_structs'] = 0
    df['num_constraints'] = 0
    df['top_tactic'] = None
    df['is_formal_proof'] = False
    
    # Create lookup dictionaries
    print("\nBuilding lookup tables...")
    
    lean_lookup = {}
    for item in parsed['lean4']:
        path = item['path']
        lean_lookup[path] = {
            'num_theorems': len(item['theorems']),
            'num_definitions': len(item['definitions']),
            'num_lemmas': len(item['lemmas']),
            'top_tactic': item['tactics'][0] if item['tactics'] else None,
            'has_theorems': len(item['theorems']) > 0,
            'is_formal_proof': item['has_qed']
        }
    
    coq_lookup = {}
    for item in parsed['coq']:
        path = item['path']
        coq_lookup[path] = {
            'num_theorems': len(item['theorems']),
            'num_definitions': len(item['definitions']),
            'num_lemmas': len(item['lemmas']),
            'top_tactic': item['tactics'][0] if item['tactics'] else None,
            'has_theorems': len(item['theorems']) > 0,
            'is_formal_proof': item['has_qed']
        }
    
    mzn_lookup = {}
    for item in parsed['minizinc']:
        path = item['path']
        mzn_lookup[path] = {
            'num_constraints': item['num_constraints'],
            'has_theorems': False,
            'is_formal_proof': True
        }
    
    rust_lookup = {}
    for item in parsed['rust']:
        path = item['path']
        rust_lookup[path] = {
            'num_functions': len(item['functions']),
            'num_structs': len(item['structs']),
            'has_theorems': False,
            'is_formal_proof': False
        }
    
    # Update dataframe
    print("\nUpdating dataframe...")
    
    updated_count = 0
    
    for idx, row in df.iterrows():
        path = row['compressed']
        
        # Check Lean4
        if path in lean_lookup:
            for key, value in lean_lookup[path].items():
                df.at[idx, key] = value
            updated_count += 1
        
        # Check Coq
        elif path in coq_lookup:
            for key, value in coq_lookup[path].items():
                df.at[idx, key] = value
            updated_count += 1
        
        # Check MiniZinc
        elif path in mzn_lookup:
            for key, value in mzn_lookup[path].items():
                df.at[idx, key] = value
            updated_count += 1
        
        # Check Rust
        elif path in rust_lookup:
            for key, value in rust_lookup[path].items():
                df.at[idx, key] = value
            updated_count += 1
    
    print(f"Updated {updated_count:,} files")
    
    # Statistics
    print("\n\nSTATISTICS")
    print("=" * 80)
    
    print(f"\nFiles with theorems: {df['has_theorems'].sum():,}")
    print(f"Files with formal proofs: {df['is_formal_proof'].sum():,}")
    
    print(f"\nTotal theorems: {df['num_theorems'].sum():,}")
    print(f"Total definitions: {df['num_definitions'].sum():,}")
    print(f"Total lemmas: {df['num_lemmas'].sum():,}")
    print(f"Total functions: {df['num_functions'].sum():,}")
    print(f"Total structs: {df['num_structs'].sum():,}")
    print(f"Total constraints: {df['num_constraints'].sum():,}")
    
    # Top tactics
    print(f"\nTop tactics:")
    top_tactics = df[df['top_tactic'].notna()]['top_tactic'].value_counts().head(10)
    for tactic, count in top_tactics.items():
        print(f"  {tactic}: {count}")
    
    # By class
    print(f"\n\nFORMAL PROOFS BY CLASS")
    print("-" * 80)
    
    for cls in ['very_low', 'low', 'medium', 'high', 'very_high']:
        subset = df[df['natural_class'] == cls]
        formal_count = subset['is_formal_proof'].sum()
        theorem_count = subset['has_theorems'].sum()
        print(f"{cls:12s}: {formal_count:5,} formal proofs, {theorem_count:5,} with theorems")
    
    # By extension
    print(f"\n\nFORMAL PROOFS BY EXTENSION")
    print("-" * 80)
    
    for ext in ['lean', 'v', 'coq', 'mzn', 'rs']:
        subset = df[df['extension'] == ext]
        if len(subset) > 0:
            formal_count = subset['is_formal_proof'].sum()
            theorem_count = subset['has_theorems'].sum()
            print(f"{ext:8s}: {len(subset):7,} files, {formal_count:5,} formal, {theorem_count:5,} theorems")
    
    # Save updated parquet
    print("\n\nSAVING UPDATED PARQUET")
    print("-" * 80)
    
    output_file = 'indexed_files_with_formal.parquet'
    df.to_parquet(output_file, compression='snappy')
    
    # Check file size
    import os
    size_mb = os.path.getsize(output_file) / (1024 * 1024)
    print(f"✅ Saved to {output_file}")
    print(f"   Size: {size_mb:.1f} MB")
    print(f"   Rows: {len(df):,}")
    print(f"   Columns: {len(df.columns)}")
    
    # Show new columns
    print(f"\n\nNEW COLUMNS ADDED")
    print("-" * 80)
    new_cols = ['has_theorems', 'num_theorems', 'num_definitions', 'num_lemmas',
                'num_functions', 'num_structs', 'num_constraints', 'top_tactic', 
                'is_formal_proof']
    for col in new_cols:
        non_zero = (df[col] != 0).sum() if col.startswith('num_') else df[col].sum()
        print(f"  {col:20s}: {non_zero:,} non-zero/true")
    
    print("\n\n" + "=" * 80)
    print("QED: Parquet updated with formal file data!")
    print("=" * 80)

if __name__ == '__main__':
    main()
