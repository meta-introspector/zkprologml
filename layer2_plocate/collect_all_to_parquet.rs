use std::process::Command;
use std::io::{BufRead, BufReader, Write};
use std::fs;
use std::sync::Arc;
use parquet::arrow::ArrowWriter;
use parquet::file::properties::WriterProperties;
use arrow::array::{StringArray, UInt64Array, BinaryArray};
use arrow::record_batch::RecordBatch;
use arrow::datatypes::{Schema, Field, DataType};
use flate2::Compression;
use flate2::write::GzEncoder;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // All our new terms from this session
    let terms = vec![
        "athena", "urania", "kurt", "umberto",
        "godel", "platonic", "monster", "genus_zero",
        "minizinc", "lean4", "lmfdb", "perf_trace",
    ];
    
    println!("📦 Collecting ALL terms to parquet\n");
    
    for term in &terms {
        println!("Processing: {}", term);
        
        let output = Command::new("plocate")
            .args(["-i", term])
            .output()?;
        
        let reader = BufReader::new(&output.stdout[..]);
        let mut paths = Vec::new();
        let mut sizes = Vec::new();
        let mut compressed_bytes = Vec::new();
        let mut search_terms = Vec::new();
        
        for line in reader.lines().filter_map(|l| l.ok()) {
            let size = fs::metadata(&line).map(|m| m.len()).unwrap_or(0);
            
            let mut encoder = GzEncoder::new(Vec::new(), Compression::default());
            encoder.write_all(line.as_bytes())?;
            let compressed = encoder.finish()?;
            
            paths.push(line);
            sizes.push(size);
            compressed_bytes.push(compressed);
            search_terms.push(term.to_string());
        }
        
        if paths.is_empty() {
            println!("  No results\n");
            continue;
        }
        
        println!("  Found: {} files", paths.len());
        
        let schema = Arc::new(Schema::new(vec![
            Field::new("search_term", DataType::Utf8, false),
            Field::new("file_path", DataType::Utf8, false),
            Field::new("file_size", DataType::UInt64, false),
            Field::new("compressed_bytes", DataType::Binary, false),
        ]));
        
        let batch = RecordBatch::try_new(
            schema.clone(),
            vec![
                Arc::new(StringArray::from(search_terms)),
                Arc::new(StringArray::from(paths)),
                Arc::new(UInt64Array::from(sizes)),
                Arc::new(BinaryArray::from_iter_values(compressed_bytes.iter().map(|v| v.as_slice()))),
            ],
        )?;
        
        let file = fs::File::create(format!("{}_search.parquet", term))?;
        let props = WriterProperties::builder().build();
        let mut writer = ArrowWriter::try_new(file, schema, Some(props))?;
        writer.write(&batch)?;
        writer.close()?;
        
        println!("  ✅ Saved: {}_search.parquet\n", term);
    }
    
    println!("✅ All terms collected to parquet!");
    
    Ok(())
}
