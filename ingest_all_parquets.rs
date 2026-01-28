use parquet::file::reader::{FileReader, SerializedFileReader};
use parquet::record::RowAccessor;
use std::fs::File;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔍 Reading lists_of_lists to find all parquet files\n");
    
    let file = File::open("/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/lists_of_lists.parquet")?;
    let reader = SerializedFileReader::new(file)?;
    
    println!("📦 Found {} parquet files listed\n", reader.metadata().file_metadata().num_rows());
    
    let mut parquet_paths = Vec::new();
    
    for row in reader.get_row_iter(None)? {
        if let Ok(path_field) = row.get_string(1) {
            parquet_paths.push(path_field.to_string());
        }
    }
    
    println!("📋 Parquet files to analyze:\n");
    for (i, path) in parquet_paths.iter().enumerate().take(20) {
        println!("  {}. {}", i+1, path);
    }
    
    if parquet_paths.len() > 20 {
        println!("  ... and {} more\n", parquet_paths.len() - 20);
    }
    
    // Now read each parquet and look for code patterns
    println!("\n🔬 Analyzing parquets for code patterns...\n");
    
    for path in parquet_paths.iter().take(10) {
        if !std::path::Path::new(path).exists() {
            continue;
        }
        
        println!("📊 {}", path);
        
        match File::open(path) {
            Ok(file) => {
                match SerializedFileReader::new(file) {
                    Ok(reader) => {
                        let metadata = reader.metadata();
                        let rows = metadata.file_metadata().num_rows();
                        let cols = metadata.file_metadata().schema().get_fields().len();
                        
                        println!("  Rows: {}, Columns: {}", rows, cols);
                        
                        // Check column names for code-related fields
                        for field in metadata.file_metadata().schema().get_fields() {
                            let name = field.name().to_lowercase();
                            if name.contains("code") || name.contains("source") || 
                               name.contains("file") || name.contains("path") ||
                               name.contains("content") || name.contains("text") {
                                println!("    🔍 Found: {}", field.name());
                            }
                        }
                    }
                    Err(e) => println!("  ⚠️  Error reading: {}", e),
                }
            }
            Err(e) => println!("  ⚠️  Cannot open: {}", e),
        }
        println!();
    }
    
    Ok(())
}
