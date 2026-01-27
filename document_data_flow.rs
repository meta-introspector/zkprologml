use std::fs;
use std::path::Path;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("📖 Documenting program data flow (domain → range)\n");
    
    // Calculate actual values
    let term_count = count_lines("layer1_terms/ranked_terms.txt")?;
    let parquet_count = count_files("data/parquets", "parquet")?;
    let parquet_size = dir_size("data/parquets")?;
    let chord_count = count_files("data/chords", "txt")?;
    let chord_size = dir_size("data/chords")?;
    let layer_count = count_files("layers", "")?;
    let layer_size = dir_size("layers")?;
    let proof_count = count_files("data/proofs", "lean")?;
    let proof_size = dir_size("data/proofs")?;
    let doc_count = count_files("data/docs", "md")?;
    let doc_size = dir_size("data/docs")?;
    
    println!("Calculated values:");
    println!("  Terms: {}", term_count);
    println!("  Parquets: {} files, {} MB", parquet_count, parquet_size / 1_000_000);
    println!("  Chords: {} files, {} MB", chord_count, chord_size / 1_000_000);
    println!("  Layers: {} files, {} MB", layer_count, layer_size / 1_000_000);
    println!();
    
    let mut doc = String::from("# Program Data Flow Documentation\n\n");
    doc.push_str("## Calculated Statistics\n\n");
    doc.push_str(&format!("- **Terms**: {} keywords\n", term_count));
    doc.push_str(&format!("- **Parquets**: {} files, {:.1} MB\n", parquet_count, parquet_size as f64 / 1_000_000.0));
    doc.push_str(&format!("- **Chords**: {} files, {:.1} MB\n", chord_count, chord_size as f64 / 1_000_000.0));
    doc.push_str(&format!("- **Layers**: {} files, {:.1} MB\n", layer_count, layer_size as f64 / 1_000_000.0));
    doc.push_str(&format!("- **Proofs**: {} files, {} KB\n", proof_count, proof_size / 1_000));
    doc.push_str(&format!("- **Docs**: {} files, {} KB\n\n", doc_count, doc_size / 1_000));
    
    let total = parquet_size + chord_size + layer_size + proof_size + doc_size;
    doc.push_str(&format!("**Total: {:.1} MB**\n\n", total as f64 / 1_000_000.0));
    
    doc.push_str("## Data Flow\n\n");
    doc.push_str(&format!("```\nTerms ({}) → Plocate → Parquets ({} files)\n", term_count, parquet_count));
    doc.push_str("         ↓\n");
    doc.push_str("      Extract → Rank → Terms (feedback)\n");
    doc.push_str("         ↓\n");
    doc.push_str("      P×N×M Lattice\n");
    doc.push_str("         ↓\n");
    doc.push_str(&format!("      Analysis → Proofs ({} Lean files)\n```\n", proof_count));
    
    fs::write("data/docs/DATA_FLOW.md", doc)?;
    println!("✅ Saved: data/docs/DATA_FLOW.md");
    
    Ok(())
}

fn count_lines(path: &str) -> Result<usize, Box<dyn std::error::Error>> {
    Ok(fs::read_to_string(path)?.lines().count())
}

fn count_files(dir: &str, ext: &str) -> Result<usize, Box<dyn std::error::Error>> {
    let mut count = 0;
    if let Ok(entries) = fs::read_dir(dir) {
        for entry in entries.flatten() {
            let path = entry.path();
            if ext.is_empty() || path.extension().map(|e| e == ext).unwrap_or(false) {
                count += 1;
            }
        }
    }
    Ok(count)
}

fn dir_size(dir: &str) -> Result<u64, Box<dyn std::error::Error>> {
    let mut size = 0;
    if let Ok(entries) = fs::read_dir(dir) {
        for entry in entries.flatten() {
            if let Ok(meta) = entry.metadata() {
                size += meta.len();
            }
        }
    }
    Ok(size)
}
