use std::fs::File;
use parquet::file::reader::{FileReader, SerializedFileReader};
use parquet::record::RowAccessor;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let file_path = "/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/lists_of_lists.parquet";
    
    println!("📂 Reading lists_of_lists.parquet...\n");
    
    let file = File::open(file_path)?;
    let reader = SerializedFileReader::new(file)?;
    
    // Get metadata
    let metadata = reader.metadata();
    println!("Schema:");
    let schema = metadata.file_metadata().schema();
    for field in schema.get_fields() {
        println!("  {}: {:?}", field.name(), field.get_basic_info().logical_type());
    }
    println!();
    
    println!("Rows: {}\n", metadata.file_metadata().num_rows());
    
    // Read first 20 rows
    println!("First 20 entries:");
    println!("─────────────────────────────────────────────────────────");
    
    let mut iter = reader.get_row_iter(None)?;
    let mut count = 0;
    
    while let Some(Ok(record)) = iter.next() {
        if count >= 20 {
            break;
        }
        
        // Print all fields in the record
        println!("{}: {:?}", count, record);
        count += 1;
    }
    
    println!("\n✅ Total rows shown: {}", count);
    
    Ok(())
}
