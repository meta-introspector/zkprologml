// read_parquet.rs - Read parquet and add ZK URL labels

use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};

fn prime_to_frequency(prime: u64) -> f64 {
    match prime {
        2 => 440.0, 3 => 493.88, 5 => 523.25, 7 => 587.33,
        11 => 659.25, 13 => 698.46, 17 => 783.99, 19 => 880.0,
        23 => 987.77, 29 => 1046.5, 31 => 1174.66, 37 => 1318.51,
        41 => 1396.91, 43 => 1567.98, 47 => 1760.0, 53 => 1975.53,
        59 => 2093.0, 61 => 2349.32, 67 => 2637.02, 71 => 2793.83,
        _ => 440.0,
    }
}

fn generate_zk_url(row_id: u64, file: &str) -> String {
    // Simple hash of row + file
    let hash = (row_id * 31 + file.len() as u64) % 0xFFFFFF;
    let freq = prime_to_frequency(row_id % 71 + 2);
    
    format!(
        "https://github.com/Escaped-RDFa/namespace?row={}&file={}&freq={:.2}&proof={:x}",
        row_id, file, freq, hash
    )
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: read_parquet <file.parquet>");
        std::process::exit(1);
    }
    
    let parquet_path = &args[1];
    
    // For now, read CSV version (parquet needs arrow crate)
    let csv_path = parquet_path.replace(".parquet", ".csv");
    
    let file = File::open(&csv_path)?;
    let reader = BufReader::new(file);
    
    let mut row_id = 0;
    for (i, line) in reader.lines().enumerate() {
        let line = line?;
        
        if i == 0 {
            // Header
            println!("{},zk_url", line);
            continue;
        }
        
        row_id += 1;
        let zk_url = generate_zk_url(row_id, parquet_path);
        println!("{},{}", line, zk_url);
    }
    
    Ok(())
}
