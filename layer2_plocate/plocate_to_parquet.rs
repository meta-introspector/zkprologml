use std::process::Command;
use std::io::{BufRead, BufReader};
use std::fs;
use std::sync::Arc;
use parquet::file::properties::WriterProperties;
use parquet::file::writer::SerializedFileWriter;
use parquet::schema::parser::parse_message_type;
use arrow::array::{StringArray, UInt64Array, BinaryArray};
use arrow::record_batch::RecordBatch;
use arrow::datatypes::{Schema, Field, DataType};
use flate2::Compression;
use flate2::write::GzEncoder;
use std::io::Write;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let terms = vec!["github", "search", "index", "crawler", "scraper"];
    
    for term in &terms {
        println!("Processing term: {}", term);
        
        let output = Command::new("plocate")
            .args(["-i", term])
            .output()?;
        
        if !output.status.success() {
            continue;
        }
        
        let reader = BufReader::new(&output.stdout[..]);
        let mut paths = Vec::new();
        let mut sizes = Vec::new();
        let mut compressed_names = Vec::new();
        let mut complexities = Vec::new();
        
        for line in reader.lines().filter_map(|l| l.ok()) {
            if !line.ends_with(".rs") && !line.ends_with(".parquet") && !line.contains("Cargo.toml") {
                continue;
            }
            
            let size = fs::metadata(&line).map(|m| m.len()).unwrap_or(0);
            
            let mut encoder = GzEncoder::new(Vec::new(), Compression::default());
            encoder.write_all(line.as_bytes())?;
            let compressed = encoder.finish()?;
            
            let complexity = line.matches('/').count() + line.len();
            
            paths.push(line);
            sizes.push(size);
            compressed_names.push(compressed);
            complexities.push(complexity as u64);
        }
        
        if paths.is_empty() {
            continue;
        }
        
        let schema = Arc::new(Schema::new(vec![
            Field::new("path", DataType::Utf8, false),
            Field::new("size", DataType::UInt64, false),
            Field::new("compressed_name", DataType::Binary, false),
            Field::new("complexity", DataType::UInt64, false),
        ]));
        
        let batch = RecordBatch::try_new(
            schema.clone(),
            vec![
                Arc::new(StringArray::from(paths)),
                Arc::new(UInt64Array::from(sizes)),
                Arc::new(BinaryArray::from(compressed_names)),
                Arc::new(UInt64Array::from(complexities)),
            ],
        )?;
        
        let file = fs::File::create(format!("plocate_{}.parquet", term))?;
        let props = WriterProperties::builder().build();
        
        let mut writer = parquet::arrow::ArrowWriter::try_new(file, schema, Some(props))?;
        writer.write(&batch)?;
        writer.close()?;
        
        println!("Saved: plocate_{}.parquet", term);
    }
    
    Ok(())
}
