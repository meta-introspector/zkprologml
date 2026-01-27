use std::fs;
use std::io::Read;
use std::collections::HashMap;
use rayon::prelude::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let primes = vec![2, 3, 5, 7, 11, 13, 17, 19, 23];  // P samples
    let ngram_sizes = vec![2, 3, 4, 5];  // N-gram sizes
    
    println!("🔬 Extracting P×N×M lattice: {} primes × {} n-gram sizes\n", primes.len(), ngram_sizes.len());
    
    let chord_files: Vec<_> = fs::read_dir(".")?
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().map(|s| s == "txt").unwrap_or(false))
        .filter(|e| {
            let name = e.file_name().to_string_lossy().to_string();
            name.contains("_") && !name.contains("resonance")
        })
        .collect();
    
    chord_files.par_iter().for_each(|entry| {
        let chord_file = entry.path();
        let chord_name = chord_file.file_stem().unwrap().to_string_lossy().to_string();
        
        if let Ok(content) = fs::read_to_string(&chord_file) {
            let paths: Vec<_> = content.lines().take(10).collect();  // Sample first 10 files per chord
            
            let mut lattice = Vec::new();
            
            for path in paths {
                if let Ok(mut file) = fs::File::open(path) {
                    let mut buffer = Vec::new();
                    if file.read_to_end(&mut buffer).is_ok() && buffer.len() > 100 {
                        
                        // For each prime P
                        for &prime in &primes {
                            // Sample at prime intervals
                            let samples: Vec<u8> = (0..buffer.len())
                                .step_by(prime)
                                .map(|i| buffer[i])
                                .collect();
                            
                            // For each n-gram size N
                            for &n in &ngram_sizes {
                                if samples.len() >= n {
                                    let mut ngram_counts: HashMap<Vec<u8>, usize> = HashMap::new();
                                    
                                    // Count M occurrences
                                    for window in samples.windows(n) {
                                        *ngram_counts.entry(window.to_vec()).or_insert(0) += 1;
                                    }
                                    
                                    // Top 5 n-grams
                                    let mut top: Vec<_> = ngram_counts.iter().collect();
                                    top.sort_by_key(|(_, &count)| std::cmp::Reverse(count));
                                    
                                    for (ngram, &count) in top.iter().take(5) {
                                        lattice.push(format!(
                                            "P={} N={} M={} ngram={:?}",
                                            prime, n, count, ngram
                                        ));
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if !lattice.is_empty() {
                let output = format!(
                    "chord: {}\nlattice_points: {}\n{}\n",
                    chord_name,
                    lattice.len(),
                    lattice.join("\n")
                );
                let _ = fs::write(format!("{}_lattice.txt", chord_name), output);
                println!("✅ {} → {} lattice points", chord_name, lattice.len());
            }
        }
    });
    
    Ok(())
}
