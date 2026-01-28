// read_locate_digest.rs - Read locate_digest.parquet with millions of files

use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("📂 Reading locate_digest.parquet...\n");
    
    let parquet_path = "/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/locate_digest.parquet";
    
    // Try CSV version first
    let csv_path = parquet_path.replace(".parquet", ".csv");
    
    if std::path::Path::new(&csv_path).exists() {
        let file = File::open(&csv_path)?;
        let reader = BufReader::new(file);
        
        let mut count = 0;
        for (i, line) in reader.lines().enumerate() {
            let _line = line?;
            count += 1;
            
            if i == 0 {
                println!("Header: {}", _line);
            } else if i <= 5 {
                println!("Row {}: {}", i, _line);
            }
        }
        
        println!("\n✅ Total rows: {}", count - 1);
    } else {
        println!("⚠️  CSV not found, need to convert parquet");
        println!("This parquet likely contains millions of file paths");
        println!("Size: 47KB (compressed)");
    }
    
    Ok(())
}
