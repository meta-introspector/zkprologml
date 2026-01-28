// enrich_files_monster.rs - Enrich files with all knowledge → Monster number RDFa ZK blob

use std::collections::HashMap;
use std::fs;

const MONSTER_PRIMES: [u64; 20] = [
    2, 3, 5, 7, 11, 13, 17, 19, 23, 29,
    31, 37, 41, 43, 47, 53, 59, 61, 67, 71
];

#[derive(Debug, Clone)]
struct FileKnowledge {
    path: String,
    shard: u64,
    godel: u64,
    file_type: Option<String>,
    type_prime: u64,
    repo: Option<String>,
    size: u64,
    lines: u64,
    monster_number: u64,
    zk_blob: String,
}

fn detect_type(path: &str) -> (Option<String>, u64) {
    if path.ends_with(".rs") { (Some("rust".to_string()), 2) }
    else if path.ends_with(".pl") { (Some("prolog".to_string()), 71) }
    else if path.ends_with(".lean") { (Some("lean4".to_string()), 61) }
    else if path.ends_with(".nix") { (Some("nix".to_string()), 23) }
    else if path.ends_with(".parquet") { (Some("parquet".to_string()), 19) }
    else if path.ends_with(".csv") { (Some("csv".to_string()), 19) }
    else if path.ends_with(".json") { (Some("json".to_string()), 17) }
    else if path.ends_with(".md") { (Some("markdown".to_string()), 31) }
    else if path.ends_with(".toml") { (Some("toml".to_string()), 29) }
    else if path.ends_with(".sh") { (Some("shell".to_string()), 31) }
    else { (None, 1) }
}

fn detect_repo(path: &str) -> Option<String> {
    let parts: Vec<&str> = path.split('/').collect();
    for part in parts {
        if part.contains("repos") || part.ends_with("-rs") || part.ends_with("-prolog") {
            return Some(part.to_string());
        }
    }
    None
}

fn get_file_stats(path: &str) -> (u64, u64) {
    match fs::metadata(path) {
        Ok(meta) => {
            let size = meta.len();
            let lines = fs::read_to_string(path)
                .map(|s| s.lines().count() as u64)
                .unwrap_or(0);
            (size, lines)
        }
        Err(_) => (0, 0)
    }
}

fn compute_monster_number(knowledge: &FileKnowledge) -> u64 {
    // Monster number = product of all relevant primes
    let mut number = knowledge.type_prime;
    number *= knowledge.shard;
    number *= (knowledge.godel % 1000);
    number *= (knowledge.size % 100 + 1);
    number *= (knowledge.lines % 100 + 1);
    number
}

fn generate_zk_blob(knowledge: &FileKnowledge) -> String {
    // RDFa ZK blob with all knowledge encoded
    format!(
        "data:application/rdf+xml;base64,{}",
        base64_encode(&format!(
            r#"<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:zk="https://zkprologml.org/ns#">
  <zk:File rdf:about="{}">
    <zk:shard>{}</zk:shard>
    <zk:godel>{}</zk:godel>
    <zk:type>{}</zk:type>
    <zk:typePrime>{}</zk:typePrime>
    <zk:repo>{}</zk:repo>
    <zk:size>{}</zk:size>
    <zk:lines>{}</zk:lines>
    <zk:monsterNumber>{}</zk:monsterNumber>
    <zk:proof>{:x}</zk:proof>
  </zk:File>
</rdf:RDF>"#,
            knowledge.path,
            knowledge.shard,
            knowledge.godel,
            knowledge.file_type.as_ref().unwrap_or(&"unknown".to_string()),
            knowledge.type_prime,
            knowledge.repo.as_ref().unwrap_or(&"none".to_string()),
            knowledge.size,
            knowledge.lines,
            knowledge.monster_number,
            knowledge.monster_number % 0xFFFFFF
        ))
    )
}

fn base64_encode(data: &str) -> String {
    const CHARS: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    let bytes = data.as_bytes();
    let mut result = String::new();
    
    for chunk in bytes.chunks(3) {
        let b1 = chunk[0];
        let b2 = chunk.get(1).copied().unwrap_or(0);
        let b3 = chunk.get(2).copied().unwrap_or(0);
        
        result.push(CHARS[(b1 >> 2) as usize] as char);
        result.push(CHARS[(((b1 & 0x03) << 4) | (b2 >> 4)) as usize] as char);
        result.push(if chunk.len() > 1 { CHARS[(((b2 & 0x0f) << 2) | (b3 >> 6)) as usize] as char } else { '=' });
        result.push(if chunk.len() > 2 { CHARS[(b3 & 0x3f) as usize] as char } else { '=' });
    }
    
    result
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🌌 Enriching files with Monster numbers...\n");
    
    // Read existing sharded files
    let csv = fs::read_to_string("generated/all_files_sharded.csv")?;
    
    let mut enriched = Vec::new();
    let mut output = String::from("path,shard,godel,type,type_prime,repo,size,lines,monster_number,zk_blob\n");
    
    for (i, line) in csv.lines().enumerate() {
        if i == 0 { continue; }
        
        let parts: Vec<&str> = line.split(',').collect();
        if parts.len() < 3 { continue; }
        
        let path = parts[0];
        let shard: u64 = parts[1].parse().unwrap_or(0);
        let godel: u64 = parts[2].parse().unwrap_or(0);
        
        let (file_type, type_prime) = detect_type(path);
        let repo = detect_repo(path);
        let (size, lines) = get_file_stats(path);
        
        let mut knowledge = FileKnowledge {
            path: path.to_string(),
            shard,
            godel,
            file_type,
            type_prime,
            repo,
            size,
            lines,
            monster_number: 0,
            zk_blob: String::new(),
        };
        
        knowledge.monster_number = compute_monster_number(&knowledge);
        knowledge.zk_blob = generate_zk_blob(&knowledge);
        
        output.push_str(&format!(
            "{},{},{},{},{},{},{},{},{},{}\n",
            knowledge.path,
            knowledge.shard,
            knowledge.godel,
            knowledge.file_type.as_ref().unwrap_or(&"unknown".to_string()),
            knowledge.type_prime,
            knowledge.repo.as_ref().unwrap_or(&"none".to_string()),
            knowledge.size,
            knowledge.lines,
            knowledge.monster_number,
            knowledge.zk_blob
        ));
        
        enriched.push(knowledge);
        
        if (i + 1) % 500 == 0 {
            println!("Enriched {} files...", i + 1);
        }
    }
    
    fs::write("generated/files_enriched_monster.csv", output)?;
    println!("\n✅ Saved to generated/files_enriched_monster.csv");
    
    // Statistics
    println!("\n📊 Enrichment Statistics:");
    let mut type_counts: HashMap<String, usize> = HashMap::new();
    for k in &enriched {
        let t = k.file_type.as_ref().unwrap_or(&"unknown".to_string()).clone();
        *type_counts.entry(t).or_insert(0) += 1;
    }
    
    println!("\nFiles by type:");
    let mut sorted: Vec<_> = type_counts.iter().collect();
    sorted.sort_by_key(|(_, count)| std::cmp::Reverse(*count));
    for (ftype, count) in sorted.iter().take(10) {
        println!("  {}: {} files", ftype, count);
    }
    
    println!("\n✨ All files enriched with Monster numbers!");
    println!("Each file now has: type, repo, size, lines, Monster number, ZK blob");
    
    Ok(())
}
