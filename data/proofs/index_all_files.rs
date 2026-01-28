// index_all_files.rs - Index all 3M files with semantic compression
use std::collections::HashMap;
use std::fs::File;
use std::io::{BufRead, BufReader, BufWriter, Write};
use std::process::{Command, Stdio};

#[derive(Debug)]
struct SemanticFeatures {
    level: u8,
    system: String,
    category: String,
    package: String,
    file_type: String,
    extension: String,
    depth: usize,
}

fn compress_path(path: &str) -> String {
    path.split('/')
        .map(|part| {
            if part.len() > 32 && part.contains('-') {
                // Nix store hash
                let chars: Vec<char> = part.chars().take(8).collect();
                format!("{}...", chars.iter().collect::<String>())
            } else if part.chars().count() > 20 {
                // Long name (handle UTF-8)
                let chars: Vec<char> = part.chars().take(17).collect();
                format!("{}...", chars.iter().collect::<String>())
            } else {
                part.to_string()
            }
        })
        .collect::<Vec<_>>()
        .join("/")
}

fn semantic_features(path: &str) -> SemanticFeatures {
    let depth = path.split('/').count();
    
    let level = if path == "/" { 0 }
        else if path.contains("/nix/store/") { 3 }
        else if path.contains("/bin/") { 4 }
        else { 5 };
    
    let system = if path.starts_with("/nix") { "nix" }
        else if path.starts_with("/usr") { "usr" }
        else if path.starts_with("/home") { "home" }
        else if path.starts_with("/mnt") { "mnt" }
        else { "other" }.to_string();
    
    let category = if path.contains("/store/") { "store" }
        else if path.contains("/lib/") { "lib" }
        else if path.contains("/bin/") { "bin" }
        else if path.contains("/share/") { "share" }
        else if path.contains("/src/") { "src" }
        else { "other" }.to_string();
    
    let file_type = if path.contains("/bin/") { "executable" }
        else if path.contains("/lib/") { "library" }
        else if path.contains("/share/") { "data" }
        else if path.contains("/src/") { "source" }
        else { "unknown" }.to_string();
    
    let extension = path.rsplit('.').next()
        .filter(|e| !e.contains('/'))
        .unwrap_or("none")
        .to_string();
    
    let package = path.split('/')
        .find(|p| p.contains('-') && !p.starts_with('.'))
        .unwrap_or("none")
        .to_string();
    
    SemanticFeatures {
        level,
        system,
        category,
        package,
        file_type,
        extension,
        depth,
    }
}

fn assign_godel(path: &str) -> u64 {
    let mut hash: u64 = 0;
    for byte in path.bytes() {
        hash = (hash.wrapping_mul(31).wrapping_add(byte as u64)) % 1_000_000_007;
    }
    hash % 71
}

fn index_all_files(output: &str) -> std::io::Result<()> {
    println!("Indexing all files from plocate...");
    
    let plocate = Command::new("plocate")
        .arg("")
        .stdout(Stdio::piped())
        .spawn()?;
    
    let reader = BufReader::new(plocate.stdout.unwrap());
    let file = File::create(output)?;
    let mut writer = BufWriter::new(file);
    
    // Write header
    writeln!(writer, "path,compressed,level,system,category,package,type,extension,depth,godel,shard")?;
    
    let mut count = 0;
    for line in reader.lines() {
        let path = line?;
        let compressed = compress_path(&path);
        let features = semantic_features(&path);
        let godel = assign_godel(&path);
        let shard = godel;
        
        writeln!(
            writer,
            "\"{}\",\"{}\",{},{},{},{},{},{},{},{},{}",
            path.replace('"', "\"\""),
            compressed.replace('"', "\"\""),
            features.level,
            features.system,
            features.category,
            features.package,
            features.file_type,
            features.extension,
            features.depth,
            godel,
            shard
        )?;
        
        count += 1;
        if count % 100_000 == 0 {
            println!("Indexed: {} files", count);
        }
    }
    
    println!("\nTotal files indexed: {}", count);
    println!("Output: {}", output);
    
    Ok(())
}

fn generate_filesystem_regex() -> String {
    r"^/(nix/store/[a-z0-9]{8}\.\.\.-[^/]+-V|usr/(lib|bin|share)|home/[^/]+|mnt/[^/]+)(/[^/]+)*/[^/]+\.[a-z0-9]+$".to_string()
}

fn main() {
    println!("Semantic Filesystem Indexer");
    println!("============================\n");
    
    if let Err(e) = index_all_files("indexed_files_full.csv") {
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }
    
    let regex = generate_filesystem_regex();
    println!("\nFilesystem regex: {}", regex);
    
    println!("\n✅ Complete! All files indexed with semantic compression.");
}
