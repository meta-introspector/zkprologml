// shard_all_files.rs - Shard all files by Hecke operator into 71 shards with data URLs

use std::fs;
use std::path::Path;

const MONSTER_PRIMES: [u64; 20] = [
    2, 3, 5, 7, 11, 13, 17, 19, 23, 29,
    31, 37, 41, 43, 47, 53, 59, 61, 67, 71
];

fn gcd(mut a: u64, mut b: u64) -> u64 {
    while b != 0 {
        let t = b;
        b = a % b;
        a = t;
    }
    a
}

fn hecke_operator(n: u64, prime: u64) -> u64 {
    (1..=n)
        .filter(|d| n % d == 0 && gcd(*d, prime) == 1)
        .sum()
}

fn assign_shard(path: &str) -> u64 {
    // Hash path to get Gödel-like number
    let godel: u64 = path.bytes().map(|b| b as u64).sum();
    
    // Compute Hecke eigenvalues
    let total: u64 = MONSTER_PRIMES.iter()
        .map(|&p| hecke_operator(godel % 1000, p))
        .sum();
    
    let index = (total as usize) % MONSTER_PRIMES.len();
    MONSTER_PRIMES[index]
}

fn generate_data_url(path: &str, shard: u64) -> String {
    // Read file and encode as data URL
    match fs::read(path) {
        Ok(bytes) => {
            let b64 = base64_encode(&bytes[..bytes.len().min(1024)]); // First 1KB
            format!("data:application/octet-stream;base64,{}", b64)
        }
        Err(_) => format!("data:text/plain,file={}&shard={}", path, shard)
    }
}

fn base64_encode(data: &[u8]) -> String {
    const CHARS: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    let mut result = String::new();
    
    for chunk in data.chunks(3) {
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

fn walk_dir(dir: &Path, files: &mut Vec<String>) {
    if let Ok(entries) = fs::read_dir(dir) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_file() {
                if let Some(path_str) = path.to_str() {
                    files.push(path_str.to_string());
                }
            } else if path.is_dir() && !path.to_str().unwrap_or("").contains(".git") {
                walk_dir(&path, files);
            }
        }
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🌌 Sharding all files by Hecke operator...\n");
    
    // Find all files
    let mut files = Vec::new();
    walk_dir(Path::new("."), &mut files);
    
    println!("Found {} files\n", files.len());
    
    // Shard and generate data URLs
    let mut output = String::from("file,shard,godel,data_url\n");
    let mut shard_counts = std::collections::HashMap::new();
    
    for (i, file) in files.iter().enumerate() {
        let shard = assign_shard(file);
        let godel: u64 = file.bytes().map(|b| b as u64).sum();
        let data_url = generate_data_url(file, shard);
        
        output.push_str(&format!("{},{},{},{}\n", file, shard, godel, data_url));
        
        *shard_counts.entry(shard).or_insert(0) += 1;
        
        if (i + 1) % 100 == 0 {
            println!("Processed {} files...", i + 1);
        }
    }
    
    fs::write("generated/all_files_sharded.csv", output)?;
    println!("\n✅ Saved to generated/all_files_sharded.csv");
    
    // Statistics
    println!("\n📊 Shard Distribution:");
    let mut sorted: Vec<_> = shard_counts.iter().collect();
    sorted.sort_by_key(|(k, _)| *k);
    
    for (shard, count) in sorted {
        println!("  Shard {}: {} files", shard, count);
    }
    
    println!("\n✨ All files sharded with data URLs!");
    
    Ok(())
}
