use std::fs;
use std::collections::{HashMap, HashSet};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🧹 Deduplicating Rust files using P×N×M lattice\n");
    
    // Find all .rs files
    let rs_files: Vec<_> = fs::read_dir(".")?
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().map(|ext| ext == "rs").unwrap_or(false))
        .map(|e| e.path())
        .collect();
    
    println!("Found {} Rust files\n", rs_files.len());
    
    // Group by similarity using n-grams
    let mut file_ngrams: HashMap<String, HashSet<String>> = HashMap::new();
    
    for path in &rs_files {
        let content = fs::read_to_string(path)?;
        let mut ngrams = HashSet::new();
        
        // Extract 4-grams
        for i in 0..content.len().saturating_sub(4) {
            if let Some(ng) = content.get(i..i+4) {
                ngrams.insert(ng.to_string());
            }
        }
        
        file_ngrams.insert(path.to_string_lossy().to_string(), ngrams);
    }
    
    // Find duplicates (>80% similarity)
    let mut duplicates = Vec::new();
    let mut seen = HashSet::new();
    
    for (file1, ng1) in &file_ngrams {
        if seen.contains(file1) {
            continue;
        }
        
        let mut similar = vec![file1.clone()];
        
        for (file2, ng2) in &file_ngrams {
            if file1 == file2 || seen.contains(file2) {
                continue;
            }
            
            let intersection: HashSet<_> = ng1.intersection(ng2).collect();
            let union: HashSet<_> = ng1.union(ng2).collect();
            
            let similarity = intersection.len() as f64 / union.len() as f64;
            
            if similarity > 0.8 {
                similar.push(file2.clone());
                seen.insert(file2.clone());
            }
        }
        
        if similar.len() > 1 {
            duplicates.push(similar);
        }
        
        seen.insert(file1.clone());
    }
    
    println!("📊 Duplicate groups: {}\n", duplicates.len());
    
    for (i, group) in duplicates.iter().enumerate() {
        println!("Group {}:", i+1);
        for file in group {
            println!("  - {}", file);
        }
        println!();
    }
    
    // Generate cleanup script
    let mut script = String::from("#!/bin/bash\n# Cleanup duplicates\n\n");
    
    for group in &duplicates {
        script.push_str(&format!("# Keep: {}\n", group[0]));
        for file in group.iter().skip(1) {
            script.push_str(&format!("# rm {}\n", file));
        }
        script.push_str("\n");
    }
    
    fs::write("cleanup_duplicates.sh", script)?;
    println!("✅ Saved: cleanup_duplicates.sh");
    
    Ok(())
}
