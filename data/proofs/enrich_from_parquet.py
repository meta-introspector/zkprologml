#!/usr/bin/env python3
# enrich_from_parquet.py - Enrich index using existing parquet files

import pandas as pd
import os
from pathlib import Path

def load_locate_digest():
    """Load the 3M file database"""
    parquet_path = "/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/locate_digest.parquet"
    if os.path.exists(parquet_path):
        print(f"Loading locate_digest.parquet...")
        return pd.read_parquet(parquet_path)
    return None

def infer_meaning(path, ext, category):
    """Infer semantic meaning from path"""
    path_lower = path.lower()
    
    if 'proof' in path_lower or 'theorem' in path_lower:
        return 'formal_proof'
    elif 'test' in path_lower:
        return 'test_code'
    elif 'doc' in path_lower or 'readme' in path_lower:
        return 'documentation'
    elif 'config' in path_lower or ext in ['yaml', 'toml', 'json', 'conf']:
        return 'configuration'
    elif category == 'bin':
        return 'executable_binary'
    elif category == 'lib':
        return 'library_code'
    elif category == 'src':
        return 'source_code'
    elif ext in ['rs', 'pl', 'lean', 'v', 'c', 'cpp', 'py', 'ml']:
        return 'source_code'
    elif ext in ['parquet', 'csv', 'arrow']:
        return 'data_table'
    elif ext in ['so', 'a', 'dylib']:
        return 'library_binary'
    else:
        return 'unknown'

def infer_usage(path, meaning):
    """Infer usage pattern from path and meaning"""
    path_lower = path.lower()
    
    # Hot: frequently used
    if meaning == 'executable_binary' or meaning == 'library_binary':
        return 'hot'
    elif '/bin/' in path or '/lib/' in path:
        return 'warm'
    # Warm: development files
    elif meaning == 'source_code' and any(x in path_lower for x in ['src', 'lib', 'core']):
        return 'warm'
    # Cool: tests, docs
    elif meaning in ['test_code', 'documentation']:
        return 'cool'
    # Cold: archives, old data
    elif any(x in path_lower for x in ['archive', 'backup', 'old', '2023', '2022', '2021']):
        return 'cold'
    else:
        return 'cool'

def extract_labels(path, meaning, ext, system):
    """Extract semantic labels"""
    labels = []
    path_lower = path.lower()
    
    # Extension
    if ext != 'none':
        labels.append(f'ext:{ext}')
    
    # Meaning
    labels.append(f'meaning:{meaning}')
    
    # System
    labels.append(f'system:{system}')
    
    # Language
    if ext == 'rs' or 'rust' in path_lower:
        labels.append('lang:rust')
    if ext == 'pl' or 'prolog' in path_lower:
        labels.append('lang:prolog')
    if ext == 'lean' or 'lean' in path_lower:
        labels.append('lang:lean4')
    if ext == 'v' and 'coq' in path_lower:
        labels.append('lang:coq')
    if ext in ['c', 'h']:
        labels.append('lang:c')
    if ext in ['cpp', 'cc', 'cxx']:
        labels.append('lang:cpp')
    if ext == 'py':
        labels.append('lang:python')
    
    # Domain
    if 'proof' in path_lower or 'theorem' in path_lower:
        labels.append('domain:proof')
    if 'monster' in path_lower or 'godel' in path_lower or 'hecke' in path_lower:
        labels.append('domain:math')
    if 'zk' in path_lower or 'zero' in path_lower:
        labels.append('domain:crypto')
    if 'parquet' in path_lower or 'datafusion' in path_lower:
        labels.append('domain:data')
    if 'nix' in path_lower:
        labels.append('domain:nix')
    
    return labels

def enrich_index(input_csv, output_csv):
    """Enrich index with meaning, usage, labels"""
    print(f"Loading index: {input_csv}")
    df = pd.read_csv(input_csv, on_bad_lines='skip', low_memory=False)
    
    print(f"Rows: {len(df)}")
    
    # Add new columns
    print("Computing meaning...")
    df['meaning'] = df.apply(lambda row: infer_meaning(row['path'], row['extension'], row['category']), axis=1)
    
    print("Computing usage...")
    df['usage'] = df.apply(lambda row: infer_usage(row['path'], row['meaning']), axis=1)
    
    print("Extracting labels...")
    df['labels'] = df.apply(lambda row: ';'.join(extract_labels(row['path'], row['meaning'], row['extension'], row['system'])), axis=1)
    
    # Add git repo (from path)
    print("Extracting git repos...")
    df['git_repo'] = df['path'].apply(lambda p: 'none' if '.git' not in p else p.split('.git')[0] + '.git')
    
    print(f"Saving enriched index: {output_csv}")
    df.to_csv(output_csv, index=False)
    
    print(f"\n✅ Enriched {len(df)} files")
    
    # Statistics
    print("\nMeaning distribution:")
    print(df['meaning'].value_counts().head(10))
    
    print("\nUsage distribution:")
    print(df['usage'].value_counts())
    
    return df

def convert_to_parquet(csv_file, parquet_file):
    """Convert enriched CSV to parquet"""
    print(f"\nConverting to parquet: {parquet_file}")
    df = pd.read_csv(csv_file)
    df.to_parquet(parquet_file, compression='snappy')
    print(f"✅ Parquet created: {parquet_file}")
    print(f"   Rows: {len(df)}")
    print(f"   Columns: {len(df.columns)}")
    print(f"   Size: {os.path.getsize(parquet_file) / 1024 / 1024:.2f} MB")

def main():
    print("Parquet-Based Index Enrichment")
    print("=" * 50)
    
    input_csv = "indexed_files_full.csv"
    enriched_csv = "indexed_files_enriched.csv"
    enriched_parquet = "indexed_files_enriched.parquet"
    
    # Enrich
    df = enrich_index(input_csv, enriched_csv)
    
    # Convert to parquet
    convert_to_parquet(enriched_csv, enriched_parquet)
    
    print("\n" + "=" * 50)
    print("✅ Complete! Files enriched and converted to parquet.")
    print(f"\nOutputs:")
    print(f"  CSV:     {enriched_csv}")
    print(f"  Parquet: {enriched_parquet}")

if __name__ == "__main__":
    main()
