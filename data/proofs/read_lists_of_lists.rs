// read_lists_of_lists.rs - Read lists_of_lists.parquet and index all parquets

use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🗂️  Reading lists_of_lists.parquet...\n");
    
    let parquet_path = "/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/lists_of_lists.parquet";
    
    // Convert to CSV first (parquet needs arrow crate)
    let csv_path = parquet_path.replace(".parquet", ".csv");
    
    // Check if CSV exists, if not we need to convert
    if !std::path::Path::new(&csv_path).exists() {
        eprintln!("⚠️  Need to convert parquet to CSV first");
        eprintln!("Run: parquet-tools cat {} > {}", parquet_path, csv_path);
        return Ok(());
    }
    
    let file = File::open(&csv_path)?;
    let reader = BufReader::new(file);
    
    let mut count = 0;
    for (i, line) in reader.lines().enumerate() {
        let line = line?;
        
        if i == 0 {
            println!("Schema: {}", line);
            println!();
            continue;
        }
        
        count += 1;
        if count <= 5 {
            println!("{}: {}", count, line);
        }
    }
    
    println!("\n✅ Total parquets indexed: {}", count);
    
    Ok(())
}
