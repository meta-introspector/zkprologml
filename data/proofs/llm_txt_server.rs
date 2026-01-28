// llm_txt_server.rs - WASM plugin for HuggingFace Spaces
use std::fs;
use std::path::Path;

#[derive(Debug)]
struct LLMChunk {
    id: usize,
    content: String,
    size: usize,
}

// Generate llm.txt from repo
fn generate_llm_txt() -> String {
    let mut content = String::new();
    
    content.push_str("# zkPrologML - Zero-Knowledge Prolog Meta-Language\n\n");
    content.push_str("> Universal Prolog system with Gödel encoding and Monster primes\n\n");
    
    content.push_str("## Monster Primes\n");
    content.push_str("[2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71]\n\n");
    
    content.push_str("## Architecture\n");
    content.push_str("```\n");
    content.push_str("Facts → Gödel → Hecke → ZK URLs → Proofs\n");
    content.push_str("```\n\n");
    
    content.push_str("## Files\n");
    content.push_str("- merged_constants.pl - All constants\n");
    content.push_str("- godel_lattice.csv - 384 entities\n");
    content.push_str("- perf_data.csv - Performance metrics\n\n");
    
    content
}

// Chunk content into 8KB pieces
fn chunk_content(content: &str, chunk_size: usize) -> Vec<LLMChunk> {
    let mut chunks = Vec::new();
    let bytes = content.as_bytes();
    let mut offset = 0;
    let mut id = 0;
    
    while offset < bytes.len() {
        let end = (offset + chunk_size).min(bytes.len());
        let chunk_bytes = &bytes[offset..end];
        let chunk_str = String::from_utf8_lossy(chunk_bytes).to_string();
        
        chunks.push(LLMChunk {
            id,
            content: chunk_str.clone(),
            size: chunk_str.len(),
        });
        
        offset = end;
        id += 1;
    }
    
    chunks
}

// Save chunks to disk
fn save_chunks(chunks: &[LLMChunk], output_dir: &str) {
    fs::create_dir_all(output_dir).unwrap();
    
    for chunk in chunks {
        let path = format!("{}/llm_chunk_{}.txt", output_dir, chunk.id);
        fs::write(&path, &chunk.content).unwrap();
        println!("  ✅ Saved: {} ({} bytes)", path, chunk.size);
    }
}

// HTTP handler for HuggingFace Spaces
fn handle_request(path: &str) -> String {
    if path == "/llm.txt" {
        generate_llm_txt()
    } else if path.starts_with("/chunk/") {
        let chunk_id = path.strip_prefix("/chunk/").unwrap();
        let chunk_path = format!("generated/llm_chunk_{}.txt", chunk_id);
        fs::read_to_string(&chunk_path).unwrap_or_else(|_| "Chunk not found".to_string())
    } else if path == "/chunks" {
        // List all chunks
        let mut response = String::from("Available chunks:\n");
        if let Ok(entries) = fs::read_dir("generated") {
            for entry in entries.flatten() {
                let path = entry.path();
                if path.to_str().unwrap().contains("llm_chunk") {
                    response.push_str(&format!("- {}\n", path.display()));
                }
            }
        }
        response
    } else {
        "404 Not Found".to_string()
    }
}

fn main() {
    println!("\n📝 LLM.TXT SERVER - WASM for HuggingFace");
    println!("═══════════════════════════════════════════════════════════\n");
    
    // Generate llm.txt
    println!("📝 Generating llm.txt...");
    let content = generate_llm_txt();
    fs::write("generated/llm.txt", &content).unwrap();
    println!("  ✅ Generated: {} bytes", content.len());
    
    // Chunk it
    println!("\n📦 Chunking...");
    let chunks = chunk_content(&content, 8000);
    println!("  Created {} chunks", chunks.len());
    
    // Save chunks
    println!("\n💾 Saving chunks...");
    save_chunks(&chunks, "generated");
    
    println!("\n✅ COMPLETE");
    println!("\nEndpoints:");
    println!("  GET /llm.txt       - Full content");
    println!("  GET /chunk/:id     - Specific chunk");
    println!("  GET /chunks        - List all chunks");
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_generate() {
        let content = generate_llm_txt();
        assert!(content.contains("zkPrologML"));
        assert!(content.contains("Monster Primes"));
    }
    
    #[test]
    fn test_chunk() {
        let content = "a".repeat(20000);
        let chunks = chunk_content(&content, 8000);
        assert_eq!(chunks.len(), 3);
    }
}
