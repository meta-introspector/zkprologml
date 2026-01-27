use std::fs;
use std::collections::HashMap;
use parquet::arrow::arrow_reader::ParquetRecordBatchReaderBuilder;
use arrow::array::AsArray;

const MONSTER_PRIMES: [usize; 15] = [2,3,5,7,11,13,17,19,23,29,31,41,47,59,71];

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔬 P×N×M Lattice Sampling\n");
    println!("P = primes, N = sample size, M = n-gram size, C = chord\n");
    
    // Read from parquet
    let file = fs::File::open("monster_search.parquet")?;
    let builder = ParquetRecordBatchReaderBuilder::try_new(file)?;
    let mut reader = builder.build()?;
    
    let mut samples = HashMap::new();
    
    while let Some(Ok(batch)) = reader.next() {
        let paths = batch.column(1).as_string::<i32>();
        
        for i in 0..batch.num_rows().min(100) {
            let path = paths.value(i);
            
            // Read file content
            if let Ok(content) = fs::read_to_string(path) {
                // For each prime P
                for &prime in &MONSTER_PRIMES {
                    // Sample N bytes at intervals of prime
                    let n_samples = content.len() / prime;
                    
                    // For each n-gram size M
                    for m in [2, 3, 4, 5] {
                        let mut ngrams = Vec::new();
                        
                        for sample_idx in 0..n_samples.min(10) {
                            let pos = sample_idx * prime;
                            if pos + m <= content.len() {
                                // Safe UTF-8 slice
                                if let Some(ngram) = content.get(pos..pos+m) {
                                    ngrams.push(ngram.to_string());
                                }
                            }
                        }
                        
                        // Chord = hash mod 24
                        let chord = path.bytes().map(|b| b as usize).sum::<usize>() % 24;
                        
                        // Store in lattice: (P, N, M, C)
                        let key = (prime, n_samples, m, chord);
                        samples.entry(key).or_insert_with(Vec::new).extend(ngrams);
                    }
                }
            }
        }
    }
    
    println!("✅ Sampled {} lattice points\n", samples.len());
    
    // Report
    let mut report = String::from("# P×N×M Lattice Samples\n\n");
    report.push_str("## Structure\n\n");
    report.push_str("- P: Monster prime (sampling interval)\n");
    report.push_str("- N: Number of samples\n");
    report.push_str("- M: N-gram size\n");
    report.push_str("- C: Chord (file hash mod 24)\n\n");
    
    report.push_str(&format!("## Lattice Points: {}\n\n", samples.len()));
    
    for ((p, n, m, c), ngrams) in samples.iter().take(20) {
        report.push_str(&format!("### P={}, N={}, M={}, C={}\n", p, n, m, c));
        report.push_str(&format!("N-grams: {}\n", ngrams.len()));
        for ng in ngrams.iter().take(5) {
            report.push_str(&format!("  - {:?}\n", ng));
        }
        report.push_str("\n");
    }
    
    fs::write("pnm_lattice_samples.md", report)?;
    println!("✅ Saved: pnm_lattice_samples.md");
    
    Ok(())
}
