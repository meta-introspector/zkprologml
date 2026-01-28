use std::process::Command;
use std::io::{BufRead, BufReader};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let terms = vec![
        "github", "search", "index", "crawler", "scraper",
        "octocrab", "seismic", "fuzzy", "fulltext",
    ];
    
    println!("🔍 Searching plocate for terms in .rs, .toml, and .parquet files\n");
    
    for term in &terms {
        let output = Command::new("plocate")
            .args(["-i", term])
            .output()?;
        
        if output.status.success() {
            let reader = BufReader::new(&output.stdout[..]);
            let mut rs_files = Vec::new();
            let mut parquet_files = Vec::new();
            
            for line in reader.lines().filter_map(|l| l.ok()) {
                if line.ends_with(".parquet") {
                    parquet_files.push(line);
                } else if line.ends_with(".rs") || line.contains("Cargo.toml") {
                    rs_files.push(line);
                }
            }
            
            if !rs_files.is_empty() || !parquet_files.is_empty() {
                println!("## {}", term);
                if !rs_files.is_empty() {
                    println!("  Rust files: {}", rs_files.len());
                    for f in rs_files.iter().take(3) {
                        println!("    {}", f);
                    }
                }
                if !parquet_files.is_empty() {
                    println!("  Parquet files: {}", parquet_files.len());
                    for f in parquet_files.iter().take(3) {
                        println!("    {}", f);
                    }
                }
                println!();
            }
        }
    }
    
    Ok(())
}
