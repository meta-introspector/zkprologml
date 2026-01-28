use parquet::file::reader::{FileReader, SerializedFileReader};
use std::fs::File;
use std::path::Path;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔍 Reading meta-parquets that contain file lists\n");
    
    let meta_parquets = vec![
        "/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/lists_of_lists.parquet",
        "/home/mdupont/nix-controller/index.parquet",
        "/home/mdupont/nix-controller/data/object_index.parquet",
    ];
    
    for path in meta_parquets {
        if !Path::new(path).exists() {
            println!("⚠️  Not found: {}", path);
            continue;
        }
        
        println!("📦 Reading: {}", path);
        
        let file = File::open(path)?;
        let reader = SerializedFileReader::new(file)?;
        let metadata = reader.metadata();
        
        println!("  Rows: {}", metadata.file_metadata().num_rows());
        println!("  Columns: {}", metadata.file_metadata().schema().get_fields().len());
        
        // Show schema
        for field in metadata.file_metadata().schema().get_fields() {
            println!("    - {}: {:?}", field.name(), field.get_basic_info().logical_type());
        }
        
        println!();
    }
    
    Ok(())
}
