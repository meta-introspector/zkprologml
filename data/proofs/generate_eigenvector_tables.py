#!/usr/bin/env python3
"""Generate eigenvector class matrix/table"""

import pandas as pd
import numpy as np

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
    print("\nEIGENVECTOR CLASS MATRIX")
    print("=" * 80)
    
    # Read
    df = pd.read_parquet('indexed_files_natural_classes.parquet')
    
    # Cross-tabulation: natural_class × meaning
    print("\n\n1. NATURAL CLASS × MEANING")
    print("-" * 80)
    ct1 = pd.crosstab(
        df['natural_class'], 
        df['meaning'],
        margins=True,
        margins_name='TOTAL'
    )
    print(ct1.to_string())
    
    # Cross-tabulation: natural_class × usage
    print("\n\n2. NATURAL CLASS × USAGE")
    print("-" * 80)
    ct2 = pd.crosstab(
        df['natural_class'], 
        df['usage'],
        margins=True,
        margins_name='TOTAL'
    )
    print(ct2.to_string())
    
    # Cross-tabulation: meaning × usage
    print("\n\n3. MEANING × USAGE")
    print("-" * 80)
    ct3 = pd.crosstab(
        df['meaning'], 
        df['usage'],
        margins=True,
        margins_name='TOTAL'
    )
    print(ct3.to_string())
    
    # Eigenvector statistics by class
    print("\n\n4. EIGENVECTOR STATISTICS BY CLASS")
    print("-" * 80)
    stats = df.groupby('natural_class')['eigenvector_sum'].agg([
        ('count', 'count'),
        ('mean', 'mean'),
        ('std', 'std'),
        ('min', 'min'),
        ('25%', lambda x: x.quantile(0.25)),
        ('50%', lambda x: x.quantile(0.50)),
        ('75%', lambda x: x.quantile(0.75)),
        ('max', 'max')
    ])
    print(stats.to_string())
    
    # Shard distribution by class
    print("\n\n5. SHARD DISTRIBUTION BY CLASS")
    print("-" * 80)
    shard_stats = df.groupby('natural_class')['shard'].agg([
        ('mean', 'mean'),
        ('std', 'std'),
        ('mode', lambda x: x.mode()[0] if len(x.mode()) > 0 else 0)
    ])
    print(shard_stats.to_string())
    
    # Top shards per class
    print("\n\n6. TOP 5 SHARDS PER CLASS")
    print("-" * 80)
    for cls in ['very_low', 'low', 'medium', 'high', 'very_high']:
        subset = df[df['natural_class'] == cls]
        top_shards = subset['shard'].value_counts().head(5)
        print(f"\n{cls.upper()}:")
        for shard, count in top_shards.items():
            print(f"  Shard {shard:2d}: {count:,} files ({count/len(subset)*100:.2f}%)")
    
    # Depth distribution
    print("\n\n7. DEPTH DISTRIBUTION BY CLASS")
    print("-" * 80)
    depth_stats = df.groupby('natural_class')['depth'].agg([
        ('mean', 'mean'),
        ('std', 'std'),
        ('min', 'min'),
        ('max', 'max')
    ])
    print(depth_stats.to_string())
    
    # Gödel distribution
    print("\n\n8. GÖDEL DISTRIBUTION BY CLASS")
    print("-" * 80)
    godel_stats = df.groupby('natural_class')['godel'].agg([
        ('mean', 'mean'),
        ('std', 'std'),
        ('min', 'min'),
        ('max', 'max')
    ])
    print(godel_stats.to_string())
    
    # Feature correlation matrix
    print("\n\n9. FEATURE CORRELATION MATRIX")
    print("-" * 80)
    
    # Convert categorical to numeric
    df_numeric = df.copy()
    df_numeric['meaning_num'] = df['meaning'].apply(meaning_to_num)
    df_numeric['usage_num'] = df['usage'].apply(usage_to_num)
    
    features = ['godel', 'shard', 'depth', 'meaning_num', 'usage_num', 'eigenvector_sum']
    corr = df_numeric[features].corr()
    print(corr.to_string())
    
    # Summary table
    print("\n\n10. SUMMARY TABLE")
    print("-" * 80)
    summary = pd.DataFrame({
        'Class': ['very_low', 'low', 'medium', 'high', 'very_high', 'TOTAL'],
        'Files': [
            len(df[df['natural_class'] == 'very_low']),
            len(df[df['natural_class'] == 'low']),
            len(df[df['natural_class'] == 'medium']),
            len(df[df['natural_class'] == 'high']),
            len(df[df['natural_class'] == 'very_high']),
            len(df)
        ],
        'Sum_Range': [
            '3-49',
            '50-85',
            '86-120',
            '121-149',
            '150-173',
            '3-173'
        ],
        'Mean_Sum': [
            df[df['natural_class'] == 'very_low']['eigenvector_sum'].mean(),
            df[df['natural_class'] == 'low']['eigenvector_sum'].mean(),
            df[df['natural_class'] == 'medium']['eigenvector_sum'].mean(),
            df[df['natural_class'] == 'high']['eigenvector_sum'].mean(),
            df[df['natural_class'] == 'very_high']['eigenvector_sum'].mean(),
            df['eigenvector_sum'].mean()
        ],
        'Pct': [
            len(df[df['natural_class'] == 'very_low']) / len(df) * 100,
            len(df[df['natural_class'] == 'low']) / len(df) * 100,
            len(df[df['natural_class'] == 'medium']) / len(df) * 100,
            len(df[df['natural_class'] == 'high']) / len(df) * 100,
            len(df[df['natural_class'] == 'very_high']) / len(df) * 100,
            100.0
        ]
    })
    print(summary.to_string(index=False))
    
    # Save all tables as CSV
    print("\n\nSaving tables...")
    summary.to_csv('eigenvector_class_summary.csv', index=False)
    ct1.to_csv('class_x_meaning.csv')
    ct2.to_csv('class_x_usage.csv')
    ct3.to_csv('meaning_x_usage.csv')
    stats.to_csv('stats_by_class.csv')
    shard_stats.to_csv('shard_distribution.csv')
    depth_stats.to_csv('depth_distribution.csv')
    godel_stats.to_csv('godel_distribution.csv')
    corr.to_csv('correlation_matrix.csv')
    
    print("✅ Saved 9 CSV tables:")
    print("  - eigenvector_class_summary.csv")
    print("  - class_x_meaning.csv")
    print("  - class_x_usage.csv")
    print("  - meaning_x_usage.csv")
    print("  - stats_by_class.csv")
    print("  - shard_distribution.csv")
    print("  - depth_distribution.csv")
    print("  - godel_distribution.csv")
    print("  - correlation_matrix.csv")
    
    print("\n\n" + "=" * 80)
    print("QED: All matrices generated!")
    print("=" * 80)

if __name__ == '__main__':
    main()
