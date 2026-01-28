#!/usr/bin/env python3
"""Parse all formal verification files: MiniZinc, Lean4, Coq, Rust"""

import pandas as pd
from pathlib import Path
import re
from collections import Counter, defaultdict

def parse_lean4(content):
    """Parse Lean4 file for theorems, definitions, proofs"""
    theorems = re.findall(r'theorem\s+(\w+)', content)
    definitions = re.findall(r'def\s+(\w+)', content)
    lemmas = re.findall(r'lemma\s+(\w+)', content)
    structures = re.findall(r'structure\s+(\w+)', content)
    inductives = re.findall(r'inductive\s+(\w+)', content)
    
    # Count proof tactics
    tactics = re.findall(r'by\s+(\w+)', content)
    
    return {
        'theorems': theorems,
        'definitions': definitions,
        'lemmas': lemmas,
        'structures': structures,
        'inductives': inductives,
        'tactics': tactics,
        'has_qed': 'QED' in content or '∎' in content
    }

def parse_coq(content):
    """Parse Coq file for theorems, definitions, proofs"""
    theorems = re.findall(r'Theorem\s+(\w+)', content)
    lemmas = re.findall(r'Lemma\s+(\w+)', content)
    definitions = re.findall(r'Definition\s+(\w+)', content)
    fixpoints = re.findall(r'Fixpoint\s+(\w+)', content)
    inductives = re.findall(r'Inductive\s+(\w+)', content)
    
    # Count proof tactics
    tactics = re.findall(r'\b(intros|apply|rewrite|reflexivity|induction|destruct|simpl|auto)\b', content)
    
    return {
        'theorems': theorems,
        'lemmas': lemmas,
        'definitions': definitions,
        'fixpoints': fixpoints,
        'inductives': inductives,
        'tactics': tactics,
        'has_qed': 'Qed.' in content
    }

def parse_minizinc(content):
    """Parse MiniZinc file for variables, constraints"""
    # Variables
    int_vars = re.findall(r'var\s+int:\s*(\w+)', content)
    bool_vars = re.findall(r'var\s+bool:\s*(\w+)', content)
    set_vars = re.findall(r'var\s+set\s+of\s+\w+:\s*(\w+)', content)
    
    # Constraints
    constraints = re.findall(r'constraint\s+', content)
    
    # Solve
    solve_type = None
    if 'solve satisfy' in content:
        solve_type = 'satisfy'
    elif 'solve minimize' in content:
        solve_type = 'minimize'
    elif 'solve maximize' in content:
        solve_type = 'maximize'
    
    return {
        'int_vars': int_vars,
        'bool_vars': bool_vars,
        'set_vars': set_vars,
        'num_constraints': len(constraints),
        'solve_type': solve_type
    }

def parse_rust(content):
    """Parse Rust file for functions, structs, traits"""
    functions = re.findall(r'fn\s+(\w+)', content)
    structs = re.findall(r'struct\s+(\w+)', content)
    enums = re.findall(r'enum\s+(\w+)', content)
    traits = re.findall(r'trait\s+(\w+)', content)
    impls = re.findall(r'impl\s+(?:\w+\s+for\s+)?(\w+)', content)
    
    # Count unsafe blocks
    unsafe_blocks = len(re.findall(r'unsafe\s*\{', content))
    
    return {
        'functions': functions,
        'structs': structs,
        'enums': enums,
        'traits': traits,
        'impls': impls,
        'unsafe_blocks': unsafe_blocks
    }

def main():
    print("\nPARSING FORMAL VERIFICATION FILES")
    print("=" * 80)
    
    # Read file index
    print("\nReading file index...")
    df = pd.read_parquet('indexed_files_natural_classes.parquet')
    
    # Find all relevant files
    print("\nFinding files...")
    
    lean_files = df[df['extension'] == 'lean']
    coq_files = df[df['extension'].isin(['v', 'coq'])]
    mzn_files = df[df['extension'] == 'mzn']
    rust_files = df[df['extension'] == 'rs']
    
    print(f"  Lean4: {len(lean_files):,} files")
    print(f"  Coq: {len(coq_files):,} files")
    print(f"  MiniZinc: {len(mzn_files):,} files")
    print(f"  Rust: {len(rust_files):,} files")
    
    # Parse samples from each type
    results = {
        'lean4': [],
        'coq': [],
        'minizinc': [],
        'rust': []
    }
    
    # Parse Lean4 files (sample 100)
    print("\n\nPARSING LEAN4 FILES")
    print("-" * 80)
    
    for idx, row in lean_files.head(100).iterrows():
        path = row['path'] if 'path' in row else f"/mnt/data1/nix/vendor/rust/github/{row['compressed']}"
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            parsed = parse_lean4(content)
            parsed['path'] = row['compressed']
            parsed['shard'] = row['shard']
            parsed['class'] = row['natural_class']
            results['lean4'].append(parsed)
        except:
            pass
    
    print(f"Parsed {len(results['lean4'])} Lean4 files")
    
    # Parse Coq files (sample 100)
    print("\n\nPARSING COQ FILES")
    print("-" * 80)
    
    for idx, row in coq_files.head(100).iterrows():
        path = row['path'] if 'path' in row else f"/mnt/data1/nix/vendor/rust/github/{row['compressed']}"
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            parsed = parse_coq(content)
            parsed['path'] = row['compressed']
            parsed['shard'] = row['shard']
            parsed['class'] = row['natural_class']
            results['coq'].append(parsed)
        except:
            pass
    
    print(f"Parsed {len(results['coq'])} Coq files")
    
    # Parse MiniZinc files (all, likely small number)
    print("\n\nPARSING MINIZINC FILES")
    print("-" * 80)
    
    for idx, row in mzn_files.iterrows():
        path = row['path'] if 'path' in row else f"/mnt/data1/nix/vendor/rust/github/{row['compressed']}"
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            parsed = parse_minizinc(content)
            parsed['path'] = row['compressed']
            parsed['shard'] = row['shard']
            parsed['class'] = row['natural_class']
            results['minizinc'].append(parsed)
        except:
            pass
    
    print(f"Parsed {len(results['minizinc'])} MiniZinc files")
    
    # Parse Rust files (sample 1000)
    print("\n\nPARSING RUST FILES")
    print("-" * 80)
    
    for idx, row in rust_files.head(1000).iterrows():
        path = row['path'] if 'path' in row else f"/mnt/data1/nix/vendor/rust/github/{row['compressed']}"
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            parsed = parse_rust(content)
            parsed['path'] = row['compressed']
            parsed['shard'] = row['shard']
            parsed['class'] = row['natural_class']
            results['rust'].append(parsed)
        except:
            pass
    
    print(f"Parsed {len(results['rust'])} Rust files")
    
    # Analyze results
    print("\n\n" + "=" * 80)
    print("ANALYSIS RESULTS")
    print("=" * 80)
    
    # Lean4 analysis
    if results['lean4']:
        print("\n\nLEAN4 STATISTICS:")
        print("-" * 80)
        
        total_theorems = sum(len(r['theorems']) for r in results['lean4'])
        total_defs = sum(len(r['definitions']) for r in results['lean4'])
        total_lemmas = sum(len(r['lemmas']) for r in results['lean4'])
        files_with_qed = sum(1 for r in results['lean4'] if r['has_qed'])
        
        print(f"Total theorems: {total_theorems}")
        print(f"Total definitions: {total_defs}")
        print(f"Total lemmas: {total_lemmas}")
        print(f"Files with QED: {files_with_qed}/{len(results['lean4'])}")
        
        # Top tactics
        all_tactics = []
        for r in results['lean4']:
            all_tactics.extend(r['tactics'])
        tactic_counts = Counter(all_tactics)
        print(f"\nTop 10 tactics:")
        for tactic, count in tactic_counts.most_common(10):
            print(f"  {tactic}: {count}")
        
        # Top theorems
        print(f"\nSample theorems:")
        for r in results['lean4'][:3]:
            if r['theorems']:
                print(f"  {r['path']}: {', '.join(r['theorems'][:3])}")
    
    # Coq analysis
    if results['coq']:
        print("\n\nCOQ STATISTICS:")
        print("-" * 80)
        
        total_theorems = sum(len(r['theorems']) for r in results['coq'])
        total_lemmas = sum(len(r['lemmas']) for r in results['coq'])
        total_defs = sum(len(r['definitions']) for r in results['coq'])
        files_with_qed = sum(1 for r in results['coq'] if r['has_qed'])
        
        print(f"Total theorems: {total_theorems}")
        print(f"Total lemmas: {total_lemmas}")
        print(f"Total definitions: {total_defs}")
        print(f"Files with Qed: {files_with_qed}/{len(results['coq'])}")
        
        # Top tactics
        all_tactics = []
        for r in results['coq']:
            all_tactics.extend(r['tactics'])
        tactic_counts = Counter(all_tactics)
        print(f"\nTop 10 tactics:")
        for tactic, count in tactic_counts.most_common(10):
            print(f"  {tactic}: {count}")
    
    # MiniZinc analysis
    if results['minizinc']:
        print("\n\nMINIZINC STATISTICS:")
        print("-" * 80)
        
        total_constraints = sum(r['num_constraints'] for r in results['minizinc'])
        solve_types = Counter(r['solve_type'] for r in results['minizinc'])
        
        print(f"Total constraints: {total_constraints}")
        print(f"Solve types: {dict(solve_types)}")
        
        print(f"\nSample models:")
        for r in results['minizinc'][:5]:
            print(f"  {r['path']}: {r['num_constraints']} constraints, {r['solve_type']}")
    
    # Rust analysis
    if results['rust']:
        print("\n\nRUST STATISTICS:")
        print("-" * 80)
        
        total_functions = sum(len(r['functions']) for r in results['rust'])
        total_structs = sum(len(r['structs']) for r in results['rust'])
        total_enums = sum(len(r['enums']) for r in results['rust'])
        total_unsafe = sum(r['unsafe_blocks'] for r in results['rust'])
        
        print(f"Total functions: {total_functions}")
        print(f"Total structs: {total_structs}")
        print(f"Total enums: {total_enums}")
        print(f"Total unsafe blocks: {total_unsafe}")
        
        # Most common function names
        all_functions = []
        for r in results['rust']:
            all_functions.extend(r['functions'])
        func_counts = Counter(all_functions)
        print(f"\nTop 10 function names:")
        for func, count in func_counts.most_common(10):
            print(f"  {func}: {count}")
    
    # Save parsed data
    print("\n\nSAVING PARSED DATA")
    print("-" * 80)
    
    import json
    
    # Convert to serializable format
    serializable_results = {}
    for lang, data in results.items():
        serializable_results[lang] = []
        for item in data:
            serializable_item = {}
            for key, value in item.items():
                if isinstance(value, list):
                    serializable_item[key] = value
                else:
                    serializable_item[key] = value
            serializable_results[lang].append(serializable_item)
    
    with open('parsed_formal_files.json', 'w') as f:
        json.dump(serializable_results, f, indent=2)
    
    print("✅ Saved to parsed_formal_files.json")
    
    print("\n\n" + "=" * 80)
    print("QED: All formal verification files parsed!")
    print("=" * 80)

if __name__ == '__main__':
    main()
