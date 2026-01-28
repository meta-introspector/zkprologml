#!/usr/bin/env python3
"""Export LLM activation traces to parquet meta-dataset"""

import polars as pl
import json
import re
from pathlib import Path
from datetime import datetime

def parse_log_file(log_path):
    """Parse log file into structured records"""
    records = []
    current_test = None
    
    with open(log_path) as f:
        for line in f:
            line = line.strip()
            
            # Start of test
            if match := re.match(r'🔬 Testing Gödel program (\d+)', line):
                if current_test:
                    records.append(current_test)
                current_test = {
                    'godel': int(match.group(1)),
                    'timestamp': datetime.now().isoformat(),
                    'status': 'started'
                }
            
            # File check
            elif '❌ File not found' in line:
                if current_test:
                    current_test['status'] = 'file_not_found'
                    current_test['error'] = line
            
            # Sending to LLM
            elif match := re.match(r'📤 Sending to LLM \((\d+) chars\)', line):
                if current_test:
                    current_test['prompt_length'] = int(match.group(1))
                    current_test['status'] = 'sent_to_llm'
            
            # Completed
            elif match := re.match(r'✅ Completed in ([\d.]+) seconds', line):
                if current_test:
                    current_test['duration'] = float(match.group(1))
                    current_test['status'] = 'completed'
            
            # Activations
            elif match := re.match(r'📊 Activations: (.+)', line):
                if current_test:
                    current_test['activations_raw'] = match.group(1)
    
    if current_test:
        records.append(current_test)
    
    return records

def parse_prolog_results(results_path):
    """Parse Prolog results file"""
    records = []
    
    if not Path(results_path).exists():
        return records
    
    with open(results_path) as f:
        for line in f:
            if line.startswith('result('):
                # Extract: result(godel, duration, response_length, activations)
                match = re.match(r'result\((\d+),\s*([\d.]+),\s*(\d+),\s*(.+)\)', line)
                if match:
                    records.append({
                        'godel': int(match.group(1)),
                        'duration': float(match.group(2)),
                        'response_length': int(match.group(3)),
                        'activations': match.group(4)
                    })
    
    return records

def parse_activation_matrix(csv_path):
    """Parse activation matrix CSV"""
    if not Path(csv_path).exists():
        return None
    
    return pl.read_csv(csv_path)

def parse_perf_data(perf_path):
    """Extract perf statistics"""
    if not Path(perf_path).exists():
        return {}
    
    import subprocess
    try:
        result = subprocess.run(
            ['perf', 'report', '-i', perf_path, '--stdio', '--header'],
            capture_output=True, text=True, timeout=10
        )
        
        stats = {}
        for line in result.stdout.split('\n'):
            if 'samples' in line:
                if match := re.search(r'(\d+)\s+samples', line):
                    stats['total_samples'] = int(match.group(1))
            if 'cycles' in line:
                if match := re.search(r'([\d,]+)\s+cycles', line):
                    stats['total_cycles'] = int(match.group(1).replace(',', ''))
        
        return stats
    except:
        return {}

def create_meta_dataset(base_path='generated'):
    """Create comprehensive parquet meta-dataset"""
    base = Path(base_path)
    
    # Parse all data sources
    log_records = parse_log_file(base / 'llm_activation.log')
    
    # Find latest results file
    result_files = list(base.glob('llm_activations_*.pl'))
    prolog_records = []
    if result_files:
        latest = max(result_files, key=lambda p: p.stat().st_mtime)
        prolog_records = parse_prolog_results(latest)
    
    # Parse matrix
    matrix_df = parse_activation_matrix(base / 'activation_matrix.csv')
    
    # Parse perf
    perf_stats = parse_perf_data(base / 'perf_llm_activation.data')
    
    # Create main trace dataset
    if log_records:
        trace_df = pl.DataFrame(log_records)
        trace_df.write_parquet(base / 'llm_activation_traces.parquet')
        print(f"✅ Wrote {len(log_records)} trace records to llm_activation_traces.parquet")
    
    # Create results dataset
    if prolog_records:
        results_df = pl.DataFrame(prolog_records)
        results_df.write_parquet(base / 'llm_activation_results.parquet')
        print(f"✅ Wrote {len(prolog_records)} result records to llm_activation_results.parquet")
    
    # Save matrix as parquet
    if matrix_df is not None:
        matrix_df.write_parquet(base / 'llm_activation_matrix.parquet')
        print(f"✅ Wrote activation matrix to llm_activation_matrix.parquet")
    
    # Create meta-index
    meta = {
        'dataset': 'llm_activation_lattice',
        'created': datetime.now().isoformat(),
        'trace_records': len(log_records),
        'result_records': len(prolog_records),
        'perf_stats': perf_stats,
        'files': {
            'traces': 'llm_activation_traces.parquet',
            'results': 'llm_activation_results.parquet',
            'matrix': 'llm_activation_matrix.parquet',
            'log': 'llm_activation.log',
            'perf': 'perf_llm_activation.data'
        }
    }
    
    meta_df = pl.DataFrame([meta])
    meta_df.write_parquet(base / 'llm_activation_meta.parquet')
    print(f"✅ Wrote meta-index to llm_activation_meta.parquet")
    
    # Summary
    print(f"\n📊 Meta-dataset summary:")
    print(f"   Traces: {len(log_records)}")
    print(f"   Results: {len(prolog_records)}")
    print(f"   Perf samples: {perf_stats.get('total_samples', 'N/A')}")
    print(f"   Perf cycles: {perf_stats.get('total_cycles', 'N/A')}")
    
    return meta

if __name__ == '__main__':
    import sys
    base = sys.argv[1] if len(sys.argv) > 1 else 'generated'
    create_meta_dataset(base)
