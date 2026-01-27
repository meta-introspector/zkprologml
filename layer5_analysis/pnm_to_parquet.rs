use std::fs;
use std::sync::Arc;
use std::io::Write;
use parquet::arrow::ArrowWriter;
use parquet::file::properties::WriterProperties;
use arrow::array::{StringArray, UInt64Array, BinaryArray};
use arrow::record_batch::RecordBatch;
use arrow::datatypes::{Schema, Field, DataType};
use flate2::Compression;
use flate2::write::GzEncoder;

const MONSTER_PRIMES: [usize; 15] = [2,3,5,7,11,13,17,19,23,29,31,41,47,59,71];

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔬 P×N×M Lattice Sampling to Parquet\n");
    
    // Sample our project files
    let project_files: Vec<_> = fs::read_dir(".")?
        .filter_map(|e| e.ok())
        .filter(|e| {
            let path = e.path();
            path.extension().map(|ext| ext == "rs" || ext == "md").unwrap_or(false)
        })
        .map(|e| e.path())
        .collect();
    
    println!("Sampling {} project files\n", project_files.len());
    
    let mut primes = Vec::new();
    let mut n_samples = Vec::new();
    let mut m_grams = Vec::new();
    let mut chords = Vec::new();
    let mut file_paths = Vec::new();
    let mut ngram_data = Vec::new();
    let mut counts = Vec::new();
    
    for path in project_files.iter().take(50) {
        if let Ok(content) = fs::read_to_string(path) {
            let path_str = path.to_string_lossy().to_string();
            let chord = path_str.bytes().map(|b| b as usize).sum::<usize>() % 24;
            
            // For each prime P
            for &prime in &MONSTER_PRIMES {
                let n = content.len() / prime;
                
                // For each n-gram size M
                for m in [2, 3, 4, 5] {
                    let mut ngrams = Vec::new();
                    
                    for sample_idx in 0..n.min(10) {
                        let pos = sample_idx * prime;
                        if let Some(ng) = content.get(pos..pos+m) {
                            ngrams.push(ng.to_string());
                        }
                    }
                    
                    if !ngrams.is_empty() {
                        // Compress ngrams
                        let mut encoder = GzEncoder::new(Vec::new(), Compression::default());
                        encoder.write_all(ngrams.join("|").as_bytes())?;
                        let compressed = encoder.finish()?;
                        
                        primes.push(prime as u64);
                        n_samples.push(n as u64);
                        m_grams.push(m as u64);
                        chords.push(chord as u64);
                        file_paths.push(path_str.clone());
                        ngram_data.push(compressed);
                        counts.push(ngrams.len() as u64);
                    }
                }
            }
        }
    }
    
    println!("Collected {} lattice points\n", primes.len());
    
    // Create parquet schema
    let schema = Arc::new(Schema::new(vec![
        Field::new("prime_p", DataType::UInt64, false),
        Field::new("samples_n", DataType::UInt64, false),
        Field::new("ngram_m", DataType::UInt64, false),
        Field::new("chord_c", DataType::UInt64, false),
        Field::new("file_path", DataType::Utf8, false),
        Field::new("ngram_count", DataType::UInt64, false),
        Field::new("compressed_ngrams", DataType::Binary, false),
    ]));
    
    // Create record batch
    let batch = RecordBatch::try_new(
        schema.clone(),
        vec![
            Arc::new(UInt64Array::from(primes)),
            Arc::new(UInt64Array::from(n_samples)),
            Arc::new(UInt64Array::from(m_grams)),
            Arc::new(UInt64Array::from(chords)),
            Arc::new(StringArray::from(file_paths)),
            Arc::new(UInt64Array::from(counts)),
            Arc::new(BinaryArray::from_iter_values(ngram_data.iter().map(|v| v.as_slice()))),
        ],
    )?;
    
    // Write to parquet
    let file = fs::File::create("pnm_lattice.parquet")?;
    let props = WriterProperties::builder().build();
    let mut writer = ArrowWriter::try_new(file, schema, Some(props))?;
    writer.write(&batch)?;
    writer.close()?;
    
    println!("✅ Saved: pnm_lattice.parquet");
    
    Ok(())
}
