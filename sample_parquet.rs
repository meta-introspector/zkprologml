use std::fs::File;
use std::io::Write;
use parquet::file::reader::{FileReader, SerializedFileReader};
use parquet::record::RowAccessor;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 3 {
        eprintln!("Usage: sample_parquet <file.parquet> <sample_size>");
        return Ok(());
    }
    
    let parquet_file = &args[1];
    let sample_size: usize = args[2].parse()?;
    
    println!("📊 Sampling {} rows from {}", sample_size, parquet_file);
    
    let file = File::open(parquet_file)?;
    let reader = SerializedFileReader::new(file)?;
    
    let mut output_file = File::create(format!("sample_{}.txt", 
        parquet_file.split('/').last().unwrap_or("data").replace(".parquet", "")))?;
    
    let mut count = 0;
    let mut iter = reader.get_row_iter(None)?;
    
    while let Some(Ok(record)) = iter.next() {
        if count >= sample_size {
            break;
        }
        
        // Extract first column (usually path or key)
        if let Some(field) = record.get_string(0) {
            writeln!(output_file, "{}", field)?;
            count += 1;
        }
    }
    
    println!("✅ Sampled {} rows", count);
    Ok(())
}
