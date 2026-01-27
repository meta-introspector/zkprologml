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
    println!("🔬 P×N×M Sampling from Keywords\n");
    
    // Find keyword file
    let keyword_file = find_file("layer1_terms", "ranked_terms.txt")?;
    let keywords = fs::read_to_string(&keyword_file)?;
    let keyword_bytes = keywords.as_bytes();
    let keyword_count = keywords.lines().count();
    
    println!("Source: {} ({} keywords, {} bytes)", 
             keyword_file, keyword_count, keyword_bytes.len());
    
    let mut primes = Vec::new();
    let mut n_samples = Vec::new();
    let mut m_grams = Vec::new();
    let mut chords = Vec::new();
    let mut sources = Vec::new();
    let mut ngram_data = Vec::new();
    let mut counts = Vec::new();
    
    // For each prime P
    for &prime in &MONSTER_PRIMES {
        let n = keyword_bytes.len() / prime;
        
        // For each n-gram size M
        for m in [2, 3, 4, 5] {
            let mut ngrams = Vec::new();
            
            // Sample at prime intervals
            let max_samples = n.min(100);
            for sample_idx in 0..max_samples {
                let pos = sample_idx * prime;
                if pos + m <= keyword_bytes.len() {
                    if let Ok(ng) = std::str::from_utf8(&keyword_bytes[pos..pos+m]) {
                        ngrams.push(ng.to_string());
                    }
                }
            }
            
            if !ngrams.is_empty() {
                let mut encoder = GzEncoder::new(Vec::new(), Compression::default());
                encoder.write_all(ngrams.join("|").as_bytes())?;
                let compressed = encoder.finish()?;
                
                let chord = prime % 24;
                
                primes.push(prime as u64);
                n_samples.push(n as u64);
                m_grams.push(m as u64);
                chords.push(chord as u64);
                sources.push(keyword_file.clone());
                ngram_data.push(compressed);
                counts.push(ngrams.len() as u64);
            }
        }
    }
    
    let lattice_points = primes.len();
    println!("\nCollected {} lattice points", lattice_points);
    
    // Create output path
    let output = "data/parquets/keywords_pnm_lattice.parquet";
    fs::create_dir_all("data/parquets")?;
    
    // Create schema
    let schema = Arc::new(Schema::new(vec![
        Field::new("prime_p", DataType::UInt64, false),
        Field::new("samples_n", DataType::UInt64, false),
        Field::new("ngram_m", DataType::UInt64, false),
        Field::new("chord_c", DataType::UInt64, false),
        Field::new("source", DataType::Utf8, false),
        Field::new("ngram_count", DataType::UInt64, false),
        Field::new("compressed_ngrams", DataType::Binary, false),
    ]));
    
    let batch = RecordBatch::try_new(
        schema.clone(),
        vec![
            Arc::new(UInt64Array::from(primes)),
            Arc::new(UInt64Array::from(n_samples)),
            Arc::new(UInt64Array::from(m_grams)),
            Arc::new(UInt64Array::from(chords)),
            Arc::new(StringArray::from(sources)),
            Arc::new(UInt64Array::from(counts)),
            Arc::new(BinaryArray::from_iter_values(ngram_data.iter().map(|v| v.as_slice()))),
        ],
    )?;
    
    let file = fs::File::create(output)?;
    let props = WriterProperties::builder().build();
    let mut writer = ArrowWriter::try_new(file, schema, Some(props))?;
    writer.write(&batch)?;
    writer.close()?;
    
    println!("✅ Saved: {}", output);
    
    println!("\nSummary:");
    println!("  Keywords: {}", keyword_count);
    println!("  Primes: {}", MONSTER_PRIMES.len());
    println!("  N-gram sizes: 4");
    println!("  Lattice points: {}", lattice_points);
    
    Ok(())
}

fn find_file(dir: &str, name: &str) -> Result<String, Box<dyn std::error::Error>> {
    let path = format!("{}/{}", dir, name);
    if fs::metadata(&path).is_ok() {
        Ok(path)
    } else {
        Err(format!("File not found: {}", path).into())
    }
}
