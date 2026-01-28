// hecke_shard.rs - Hecke operator sharding in Rust with Parquet output

use std::collections::HashMap;

// Monster primes
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

fn hecke_operator(godel: u64, prime: u64) -> u64 {
    // T_p(n) = sum of divisors of n coprime to p
    (1..=godel)
        .filter(|d| godel % d == 0 && gcd(*d, prime) == 1)
        .sum()
}

fn assign_to_shard(godel: u64) -> u64 {
    let total: u64 = MONSTER_PRIMES.iter()
        .map(|&p| hecke_operator(godel, p))
        .sum();
    
    let index = (total as usize) % MONSTER_PRIMES.len();
    MONSTER_PRIMES[index]
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🌌 Hecke operator sharding (Rust)...\n");
    
    // Read CSV manually
    let csv = std::fs::read_to_string("generated/godel_lattice.csv")?;
    
    let mut shards: HashMap<u64, Vec<(u64, String, String, String, u64)>> = HashMap::new();
    
    for (i, line) in csv.lines().enumerate() {
        if i == 0 { continue; } // Skip header
        
        let parts: Vec<&str> = line.split(',').collect();
        if parts.len() < 4 { continue; }
        
        let godel: u64 = parts[0].parse()?;
        let entity_type = parts[1].to_string();
        let entity_path = parts[2].trim_matches('"').to_string();
        let primes = parts[3].to_string();
        
        let shard = assign_to_shard(godel);
        let eigensum: u64 = MONSTER_PRIMES.iter()
            .map(|&p| hecke_operator(godel, p))
            .sum();
        
        shards.entry(shard)
            .or_insert_with(Vec::new)
            .push((godel, entity_type, entity_path, primes, eigensum));
        
        if godel % 50 == 0 {
            println!("Gödel {} → Shard {} (Σeigen={})", godel, shard, eigensum);
        }
    }
    
    // Write to CSV
    let mut output = String::from("godel,entity_type,entity_path,primes,shard,eigensum\n");
    
    for (shard, entities) in &shards {
        for (godel, etype, epath, primes, eigensum) in entities {
            output.push_str(&format!("{},{},{},{},{},{}\n",
                godel, etype, epath, primes, shard, eigensum));
        }
    }
    
    std::fs::write("generated/hecke_shards_rust.csv", output)?;
    
    println!("\n✅ Saved to generated/hecke_shards_rust.csv");
    
    // Statistics
    println!("\n📊 Shard distribution:");
    let mut sorted: Vec<_> = shards.iter().collect();
    sorted.sort_by_key(|(k, _)| *k);
    
    for (shard, entities) in sorted {
        println!("  Shard {}: {} entities", shard, entities.len());
    }
    
    // Convert to parquet via Python
    println!("\n📦 Converting to parquet...");
    std::process::Command::new("python3")
        .arg("-c")
        .arg("import pandas as pd; pd.read_csv('generated/hecke_shards_rust.csv').to_parquet('generated/hecke_shards.parquet')")
        .output()?;
    
    println!("✅ Saved to generated/hecke_shards.parquet");
    println!("\n✨ Hecke sharding complete!");
    
    Ok(())
}
