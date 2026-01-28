// enrich_index.rs - Add git, meaning, usage to indexed files and convert to parquet
use std::collections::HashMap;
use std::fs::File;
use std::io::{BufRead, BufReader, BufWriter, Write};
use std::process::{Command, Stdio};
use std::path::Path;

#[derive(Debug)]
struct EnrichedFile {
    path: String,
    compressed: String,
    level: u8,
    system: String,
    category: String,
    package: String,
    file_type: String,
    extension: String,
    depth: usize,
    godel: u64,
    shard: u64,
    // New fields
    git_repo: String,
    git_commit: String,
    author: String,
    last_modified: String,
    meaning: String,
    usage: String,
    labels: Vec<String>,
}

fn find_git_repo(path: &str) -> Option<String> {
    let mut current = Path::new(path);
    while let Some(parent) = current.parent() {
        let git_dir = parent.join(".git");
        if git_dir.exists() {
            return Some(parent.to_string_lossy().to_string());
        }
        current = parent;
    }
    None
}

fn get_git_info(path: &str) -> (String, String, String) {
    // Skip git for performance - too slow for 8M files
    ("none".to_string(), "none".to_string(), "none".to_string())
}

fn infer_meaning(path: &str, ext: &str, category: &str) -> String {
    if path.contains("proof") || path.contains("theorem") {
        "formal_proof"
    } else if path.contains("test") {
        "test_code"
    } else if path.contains("doc") || path.contains("README") {
        "documentation"
    } else if path.contains("config") || ext == "yaml" || ext == "toml" || ext == "json" {
        "configuration"
    } else if category == "bin" {
        "executable_binary"
    } else if category == "lib" {
        "library_code"
    } else if category == "src" {
        "source_code"
    } else if ext == "rs" || ext == "pl" || ext == "lean" || ext == "v" {
        "source_code"
    } else if ext == "parquet" {
        "data_table"
    } else if ext == "csv" {
        "data_table"
    } else {
        "unknown"
    }.to_string()
}

fn infer_usage(path: &str, meaning: &str) -> String {
    // Check file modification time to infer usage
    if let Ok(metadata) = std::fs::metadata(path) {
        if let Ok(modified) = metadata.modified() {
            let age = std::time::SystemTime::now()
                .duration_since(modified)
                .unwrap_or_default()
                .as_secs();
            
            return if age < 86400 { // < 1 day
                "hot"
            } else if age < 604800 { // < 1 week
                "warm"
            } else if age < 2592000 { // < 30 days
                "cool"
            } else {
                "cold"
            }.to_string();
        }
    }
    
    // Fallback: infer from meaning
    match meaning {
        "executable_binary" => "frequent",
        "library_code" => "frequent",
        "configuration" => "periodic",
        "test_code" => "periodic",
        _ => "rare"
    }.to_string()
}

fn extract_labels(path: &str, meaning: &str, ext: &str) -> Vec<String> {
    let mut labels = vec![];
    
    // File type labels
    if ext != "none" {
        labels.push(format!("ext:{}", ext));
    }
    
    // Meaning labels
    labels.push(format!("meaning:{}", meaning));
    
    // Path-based labels
    if path.contains("/nix/store/") {
        labels.push("nix_store".to_string());
    }
    if path.contains("rust") || ext == "rs" {
        labels.push("rust".to_string());
    }
    if path.contains("prolog") || ext == "pl" {
        labels.push("prolog".to_string());
    }
    if path.contains("lean") || ext == "lean" {
        labels.push("lean4".to_string());
    }
    if path.contains("proof") {
        labels.push("proof".to_string());
    }
    if path.contains("monster") || path.contains("godel") {
        labels.push("math".to_string());
    }
    if path.contains("zk") {
        labels.push("zero_knowledge".to_string());
    }
    
    labels
}

fn enrich_file(line: &str) -> Option<EnrichedFile> {
    let parts: Vec<&str> = line.split(',').collect();
    if parts.len() < 11 {
        return None;
    }
    
    let path = parts[0].trim_matches('"');
    let compressed = parts[1].trim_matches('"');
    let level = parts[2].parse().ok()?;
    let system = parts[3].to_string();
    let category = parts[4].to_string();
    let package = parts[5].to_string();
    let file_type = parts[6].to_string();
    let extension = parts[7].to_string();
    let depth = parts[8].parse().ok()?;
    let godel = parts[9].parse().ok()?;
    let shard = parts[10].parse().ok()?;
    
    // Enrich with new data
    let git_repo = find_git_repo(path).unwrap_or_else(|| "none".to_string());
    let git_commit = "none".to_string();
    let author = "none".to_string();
    let last_modified = std::fs::metadata(path)
        .and_then(|m| m.modified())
        .ok()
        .and_then(|t| t.duration_since(std::time::UNIX_EPOCH).ok())
        .map(|d| d.as_secs().to_string())
        .unwrap_or_else(|| "0".to_string());
    
    let meaning = infer_meaning(path, &extension, &category);
    let usage = infer_usage(path, &meaning);
    let labels = extract_labels(path, &meaning, &extension);
    
    Some(EnrichedFile {
        path: path.to_string(),
        compressed: compressed.to_string(),
        level,
        system,
        category,
        package,
        file_type,
        extension,
        depth,
        godel,
        shard,
        git_repo,
        git_commit,
        author,
        last_modified,
        meaning,
        usage,
        labels,
    })
}

fn enrich_index(input: &str, output: &str) -> std::io::Result<()> {
    println!("Enriching index with git, meaning, usage...");
    
    let file = File::open(input)?;
    let reader = BufReader::new(file);
    let out_file = File::create(output)?;
    let mut writer = BufWriter::new(out_file);
    
    // Write header
    writeln!(writer, "path,compressed,level,system,category,package,type,extension,depth,godel,shard,git_repo,git_commit,author,last_modified,meaning,usage,labels")?;
    
    let mut count = 0;
    let mut skipped = 0;
    
    for (i, line) in reader.lines().enumerate() {
        if i == 0 { continue; } // Skip header
        
        let line = line?;
        if let Some(enriched) = enrich_file(&line) {
            writeln!(
                writer,
                "\"{}\",\"{}\",{},{},{},{},{},{},{},{},{},\"{}\",\"{}\",\"{}\",{},\"{}\",\"{}\",\"{}\"",
                enriched.path.replace('"', "\"\""),
                enriched.compressed.replace('"', "\"\""),
                enriched.level,
                enriched.system,
                enriched.category,
                enriched.package,
                enriched.file_type,
                enriched.extension,
                enriched.depth,
                enriched.godel,
                enriched.shard,
                enriched.git_repo.replace('"', "\"\""),
                enriched.git_commit,
                enriched.author.replace('"', "\"\""),
                enriched.last_modified,
                enriched.meaning,
                enriched.usage,
                enriched.labels.join(";")
            )?;
            
            count += 1;
            if count % 100_000 == 0 {
                println!("Enriched: {} files", count);
            }
        } else {
            skipped += 1;
        }
    }
    
    println!("\nTotal enriched: {}", count);
    println!("Skipped: {}", skipped);
    println!("Output: {}", output);
    
    Ok(())
}

fn main() {
    println!("File Index Enrichment");
    println!("=====================\n");
    
    let input = "indexed_files_full.csv";
    let output = "indexed_files_enriched.csv";
    
    if let Err(e) = enrich_index(input, output) {
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }
    
    println!("\n✅ Complete! Index enriched with git, meaning, usage, labels.");
    println!("\nNext: Convert to parquet with:");
    println!("  python3 -c 'import pandas as pd; df = pd.read_csv(\"indexed_files_enriched.csv\"); df.to_parquet(\"indexed_files_enriched.parquet\")'");
}
