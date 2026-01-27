use std::fs;
use std::collections::HashMap;
use parquet::arrow::arrow_reader::ParquetRecordBatchReaderBuilder;
use arrow::array::AsArray;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("📊 Ranking terms by frequency\n");
    
    let parquet_files = vec![
        "athena_search.parquet",
        "urania_search.parquet", 
        "kurt_search.parquet",
        "umberto_search.parquet",
        "godel_search.parquet",
        "platonic_search.parquet",
        "monster_search.parquet",
    ];
    
    let mut term_counts: HashMap<String, usize> = HashMap::new();
    
    for file in &parquet_files {
        if !fs::metadata(file).is_ok() {
            continue;
        }
        
        let file_reader = fs::File::open(file)?;
        let builder = ParquetRecordBatchReaderBuilder::try_new(file_reader)?;
        let mut reader = builder.build()?;
        
        while let Some(Ok(batch)) = reader.next() {
            let paths = batch.column(1).as_string::<i32>();
            
            for i in 0..batch.num_rows() {
                if let Some(term) = paths.value(i).split('/').last() {
                    *term_counts.entry(term.to_string()).or_insert(0) += 1;
                }
            }
        }
    }
    
    // Sort by frequency
    let mut ranked: Vec<_> = term_counts.iter().collect();
    ranked.sort_by(|a, b| b.1.cmp(a.1));
    
    println!("✅ Ranked {} terms\n", ranked.len());
    println!("Top 50:\n");
    
    for (i, (term, count)) in ranked.iter().enumerate().take(50) {
        println!("{:3}. {:50} ({})", i+1, term, count);
    }
    
    // Save ranked list
    let output = ranked.iter()
        .map(|(term, count)| format!("{}\t{}", count, term))
        .collect::<Vec<_>>()
        .join("\n");
    
    fs::write("ranked_terms.txt", output)?;
    println!("\n✅ Saved: ranked_terms.txt");
    
    Ok(())
}
