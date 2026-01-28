// enrich_parquet.rs - Fast enrichment and parquet conversion
use std::fs::File;
use std::io::{BufRead, BufReader, BufWriter, Write};

fn infer_meaning(path: &str, ext: &str, category: &str) -> &'static str {
    let p = path.to_lowercase();
    if p.contains("proof") || p.contains("theorem") { "formal_proof" }
    else if p.contains("test") { "test_code" }
    else if p.contains("doc") || p.contains("readme") { "documentation" }
    else if p.contains("config") || matches!(ext, "yaml" | "toml" | "json" | "conf") { "configuration" }
    else if category == "bin" { "executable_binary" }
    else if category == "lib" { "library_code" }
    else if category == "src" { "source_code" }
    else if matches!(ext, "rs" | "pl" | "lean" | "v" | "c" | "cpp" | "py" | "ml") { "source_code" }
    else if matches!(ext, "parquet" | "csv" | "arrow") { "data_table" }
    else if matches!(ext, "so" | "a" | "dylib") { "library_binary" }
    else { "unknown" }
}

fn infer_usage(path: &str, meaning: &str) -> &'static str {
    let p = path.to_lowercase();
    if meaning == "executable_binary" || meaning == "library_binary" { "hot" }
    else if path.contains("/bin/") || path.contains("/lib/") { "warm" }
    else if meaning == "source_code" && (p.contains("src") || p.contains("lib") || p.contains("core")) { "warm" }
    else if meaning == "test_code" || meaning == "documentation" { "cool" }
    else if p.contains("archive") || p.contains("backup") || p.contains("old") || p.contains("2023") || p.contains("2022") { "cold" }
    else { "cool" }
}

fn extract_labels(path: &str, meaning: &str, ext: &str, system: &str) -> String {
    let mut labels = vec![format!("meaning:{}", meaning), format!("system:{}", system)];
    let p = path.to_lowercase();
    
    if ext != "none" { labels.push(format!("ext:{}", ext)); }
    
    // Languages
    if ext == "rs" || p.contains("rust") { labels.push("lang:rust".to_string()); }
    if ext == "pl" || p.contains("prolog") { labels.push("lang:prolog".to_string()); }
    if ext == "lean" { labels.push("lang:lean4".to_string()); }
    if ext == "v" && p.contains("coq") { labels.push("lang:coq".to_string()); }
    if ext == "c" || ext == "h" { labels.push("lang:c".to_string()); }
    if matches!(ext, "cpp" | "cc" | "cxx") { labels.push("lang:cpp".to_string()); }
    if ext == "py" { labels.push("lang:python".to_string()); }
    
    // Domains
    if p.contains("proof") || p.contains("theorem") { labels.push("domain:proof".to_string()); }
    if p.contains("monster") || p.contains("godel") || p.contains("hecke") { labels.push("domain:math".to_string()); }
    if p.contains("zk") || p.contains("zero") { labels.push("domain:crypto".to_string()); }
    if p.contains("parquet") || p.contains("datafusion") { labels.push("domain:data".to_string()); }
    if p.contains("nix") { labels.push("domain:nix".to_string()); }
    
    labels.join(";")
}

fn enrich_index(input: &str, output: &str) -> std::io::Result<()> {
    println!("Enriching index: {}", input);
    
    let file = File::open(input)?;
    let reader = BufReader::new(file);
    let out = File::create(output)?;
    let mut writer = BufWriter::new(out);
    
    writeln!(writer, "path,compressed,level,system,category,package,type,extension,depth,godel,shard,meaning,usage,labels")?;
    
    let mut count = 0;
    for (i, line) in reader.lines().enumerate() {
        if i == 0 { continue; }
        
        let line = line?;
        let parts: Vec<&str> = line.splitn(11, ',').collect();
        if parts.len() < 11 { continue; }
        
        let path = parts[0].trim_matches('"');
        let ext = parts[7];
        let category = parts[4];
        let system = parts[3];
        
        let meaning = infer_meaning(path, ext, category);
        let usage = infer_usage(path, meaning);
        let labels = extract_labels(path, meaning, ext, system);
        
        writeln!(writer, "{},{},{},{}", line, meaning, usage, labels)?;
        
        count += 1;
        if count % 100_000 == 0 {
            println!("Enriched: {} files", count);
        }
    }
    
    println!("\n✅ Total enriched: {}", count);
    println!("Output: {}", output);
    Ok(())
}

fn main() {
    println!("Fast Index Enrichment\n");
    
    if let Err(e) = enrich_index("indexed_files_full.csv", "indexed_files_enriched.csv") {
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }
    
    println!("\n✅ Complete! Convert to parquet with:");
    println!("  python3 -c 'import pandas as pd; pd.read_csv(\"indexed_files_enriched.csv\").to_parquet(\"indexed_files_enriched.parquet\")'");
}
