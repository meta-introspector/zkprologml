use std::fs;
use std::sync::Arc;
use parquet::arrow::arrow_reader::ParquetRecordBatchReaderBuilder;
use arrow::array::AsArray;
use std::collections::HashSet;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("📊 Extracting all terms from parquet files\n");
    
    let parquet_files = vec![
        "athena_search.parquet",
        "urania_search.parquet", 
        "kurt_search.parquet",
        "umberto_search.parquet",
        "godel_search.parquet",
        "platonic_search.parquet",
        "monster_search.parquet",
    ];
    
    let mut all_terms = HashSet::new();
    
    for file in &parquet_files {
        if !fs::metadata(file).is_ok() {
            continue;
        }
        
        println!("Reading: {}", file);
        
        let file_reader = fs::File::open(file)?;
        let builder = ParquetRecordBatchReaderBuilder::try_new(file_reader)?;
        let mut reader = builder.build()?;
        
        while let Some(Ok(batch)) = reader.next() {
            let paths = batch.column(1).as_string::<i32>();
            
            for i in 0..batch.num_rows() {
                if let Some(path) = paths.value(i).split('/').last() {
                    all_terms.insert(path.to_string());
                }
            }
        }
    }
    
    println!("\n✅ Extracted {} unique terms\n", all_terms.len());
    
    let mut terms: Vec<_> = all_terms.iter().collect();
    terms.sort();
    
    for (i, term) in terms.iter().enumerate().take(50) {
        println!("{}: {}", i, term);
    }
    
    if terms.len() > 50 {
        println!("... and {} more", terms.len() - 50);
    }
    
    // Save to file
    let output = terms.iter().map(|s| s.as_str()).collect::<Vec<_>>().join("\n");
    fs::write("extracted_terms.txt", output)?;
    println!("\n✅ Saved: extracted_terms.txt");
    
    Ok(())
}
