use std::fs::File;
use std::io::{BufRead, BufReader};
use std::process::Command;
use rayon::prelude::*;
use flate2::write::GzEncoder;
use flate2::Compression;
use std::io::Write;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let terms = vec!["github", "search", "index", "crawler", "scraper", "octocrab", "fuzzy", "fulltext"];
    
    println!("🚀 Parallel plocate scan with {} CPUs", rayon::current_num_threads());
    
    terms.par_iter().for_each(|term| {
        if let Ok(output) = Command::new("plocate")
            .args(["-i", term])
            .output() {
            
            let reader = BufReader::new(&output.stdout[..]);
            let results: Vec<_> = reader.lines()
                .filter_map(|l| l.ok())
                .filter(|l| l.ends_with(".rs") || l.ends_with(".parquet") || l.contains("Cargo.toml"))
                .collect();
            
            // Group by compressed hash (harmonic chord)
            let mut chords: Vec<Vec<String>> = vec![Vec::new(); 24];
            
            for path in results {
                let mut encoder = GzEncoder::new(Vec::new(), Compression::fast());
                let _ = encoder.write_all(path.as_bytes());
                if let Ok(compressed) = encoder.finish() {
                    let hash = compressed.iter().fold(0u64, |acc, &b| acc.wrapping_add(b as u64));
                    let chord = (hash % 24) as usize;
                    chords[chord].push(path);
                }
            }
            
            // Save each chord
            for (i, chord) in chords.iter().enumerate() {
                if !chord.is_empty() {
                    let filename = format!("{}_{:02}.txt", term, i);
                    if let Ok(_) = std::fs::write(&filename, chord.join("\n")) {
                        println!("✅ {} chord {}: {} files", term, i, chord.len());
                    }
                }
            }
        }
    });
    
    Ok(())
}
