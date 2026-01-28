// heat_signature.rs - Generate complete heat signature with all metadata

use std::fs;
use std::process::Command;

#[derive(Debug)]
struct HeatSignature {
    instructions: u64,
    executions: u64,
    git_repos: Vec<String>,
    lines_of_code: u64,
    authors: Vec<String>,
    commits: Vec<String>,
    concepts: Vec<String>,
}

fn count_instructions(file: &str) -> u64 {
    match fs::read_to_string(file) {
        Ok(content) => content.lines()
            .filter(|line| !line.trim().is_empty() && !line.trim().starts_with("//"))
            .count() as u64,
        Err(_) => 0
    }
}

fn get_git_repos() -> Vec<String> {
    let output = Command::new("find")
        .args(&[".", "-name", ".git", "-type", "d"])
        .output()
        .expect("Failed to find git repos");
    
    String::from_utf8_lossy(&output.stdout)
        .lines()
        .map(|s| s.replace("/.git", ""))
        .collect()
}

fn count_lines_of_code() -> u64 {
    let output = Command::new("find")
        .args(&[".", "-type", "f", "-name", "*.rs", "-o", "-name", "*.pl", "-o", "-name", "*.lean"])
        .output()
        .expect("Failed to find code files");
    
    let content = String::from_utf8_lossy(&output.stdout);
    let files: Vec<&str> = content.lines().collect();
    
    let mut total = 0;
    for file in files {
        if let Ok(content) = fs::read_to_string(file) {
            total += content.lines().count() as u64;
        }
    }
    total
}

fn get_authors() -> Vec<String> {
    let output = Command::new("git")
        .args(&["log", "--format=%an", "--all"])
        .output()
        .expect("Failed to get authors");
    
    let mut authors: Vec<String> = String::from_utf8_lossy(&output.stdout)
        .lines()
        .map(|s| s.to_string())
        .collect();
    
    authors.sort();
    authors.dedup();
    authors
}

fn get_commits() -> Vec<String> {
    let output = Command::new("git")
        .args(&["log", "--oneline", "-20"])
        .output()
        .expect("Failed to get commits");
    
    String::from_utf8_lossy(&output.stdout)
        .lines()
        .map(|s| s.to_string())
        .collect()
}

fn extract_concepts() -> Vec<String> {
    vec![
        "Gödel encoding".to_string(),
        "Hecke operators".to_string(),
        "Monster group primes".to_string(),
        "ZK RDF shards".to_string(),
        "Universe hierarchy".to_string(),
        "Parquet of parquets".to_string(),
        "Prime resonance".to_string(),
        "Harmonic vectors".to_string(),
        "Self-referential system".to_string(),
        "Lean4 ↔ Prolog co-reasoning".to_string(),
    ]
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔥 GENERATING HEAT SIGNATURE\n");
    
    // Count instructions
    let instructions = count_instructions("prove_it.rs");
    println!("📊 Instructions: {}", instructions);
    
    // Count executions (from proof)
    let executions = 5; // 5 proofs executed
    println!("⚡ Executions: {}", executions);
    
    // Get git repos
    let repos = get_git_repos();
    println!("📁 Git repos: {}", repos.len());
    for repo in &repos {
        println!("   - {}", repo);
    }
    
    // Count lines of code
    let loc = count_lines_of_code();
    println!("\n📝 Lines of code: {}", loc);
    
    // Get authors
    let authors = get_authors();
    println!("\n👥 Authors: {}", authors.len());
    for author in &authors {
        println!("   - {}", author);
    }
    
    // Get recent commits
    let commits = get_commits();
    println!("\n💾 Recent commits: {}", commits.len());
    for (i, commit) in commits.iter().take(5).enumerate() {
        println!("   {}. {}", i + 1, commit);
    }
    
    // Extract concepts
    let concepts = extract_concepts();
    println!("\n🧠 Concepts: {}", concepts.len());
    for (i, concept) in concepts.iter().enumerate() {
        println!("   {}. {}", i + 1, concept);
    }
    
    // Create heat signature
    let signature = HeatSignature {
        instructions,
        executions,
        git_repos: repos.clone(),
        lines_of_code: loc,
        authors: authors.clone(),
        commits: commits.clone(),
        concepts: concepts.clone(),
    };
    
    // Calculate total heat
    let heat = instructions * executions + loc + (repos.len() as u64 * 1000);
    
    println!("\n═══════════════════════════════════════════════════════════");
    println!("🔥 TOTAL HEAT: {}", heat);
    println!("═══════════════════════════════════════════════════════════");
    
    // Generate heat chunks
    println!("\n📦 HEAT CHUNKS:\n");
    
    let chunk_size = heat / 71; // Divide by 71 Monster primes
    for i in 0..20 {
        let prime = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71][i];
        let chunk_heat = chunk_size * prime;
        
        println!("Chunk {} (prime {}):", i + 1, prime);
        println!("  Heat: {}", chunk_heat);
        println!("  Instructions: {}", instructions / 20);
        println!("  Executions: {}", if i < executions as usize { 1 } else { 0 });
        println!("  Repos: {}", if i < repos.len() { &repos[i] } else { "none" });
        println!("  LOC: {}", loc / 20);
        println!("  Concept: {}", if i < concepts.len() { &concepts[i] } else { "none" });
        println!();
    }
    
    // Save signature
    let json = format!(r#"{{
  "instructions": {},
  "executions": {},
  "git_repos": {},
  "lines_of_code": {},
  "authors": {},
  "commits": {},
  "concepts": {},
  "total_heat": {}
}}"#,
        instructions,
        executions,
        repos.len(),
        loc,
        authors.len(),
        commits.len(),
        concepts.len(),
        heat
    );
    
    fs::write("generated/heat_signature.json", json)?;
    println!("✅ Saved to generated/heat_signature.json");
    
    println!("\n🔥 HEAT SIGNATURE COMPLETE 🔥\n");
    
    Ok(())
}
