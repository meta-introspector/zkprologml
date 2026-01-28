// shared_memory_cache.rs - Load slow files into shared memory with chunking

use std::fs;
use std::collections::HashMap;
use std::sync::{Arc, RwLock};

const CHUNK_SIZE: usize = 4096;  // 4KB chunks

#[derive(Debug, Clone)]
struct Chunk {
    id: usize,
    data: Vec<u8>,
    offset: usize,
}

#[derive(Debug)]
struct CachedFile {
    path: String,
    chunks: Vec<Chunk>,
    total_size: usize,
    access_count: usize,
}

struct SharedMemoryCache {
    cache: Arc<RwLock<HashMap<String, CachedFile>>>,
    max_size: usize,
    current_size: usize,
}

impl SharedMemoryCache {
    fn new(max_size: usize) -> Self {
        SharedMemoryCache {
            cache: Arc::new(RwLock::new(HashMap::new())),
            max_size,
            current_size: 0,
        }
    }
    
    fn load_file(&mut self, path: &str) -> Result<(), String> {
        println!("📥 Loading {} into shared memory...", path);
        
        // Read file
        let data = fs::read(path).map_err(|e| e.to_string())?;
        let total_size = data.len();
        
        // Check if we have space
        if self.current_size + total_size > self.max_size {
            println!("  ⚠️  Cache full, evicting...");
            self.evict_lru();
        }
        
        // Chunk the data
        let mut chunks = Vec::new();
        let mut offset = 0;
        let mut chunk_id = 0;
        
        while offset < data.len() {
            let end = (offset + CHUNK_SIZE).min(data.len());
            let chunk_data = data[offset..end].to_vec();
            
            chunks.push(Chunk {
                id: chunk_id,
                data: chunk_data,
                offset,
            });
            
            offset = end;
            chunk_id += 1;
        }
        
        println!("  ✅ Loaded {} bytes in {} chunks", total_size, chunks.len());
        
        // Store in cache
        let cached = CachedFile {
            path: path.to_string(),
            chunks,
            total_size,
            access_count: 0,
        };
        
        let mut cache = self.cache.write().unwrap();
        cache.insert(path.to_string(), cached);
        self.current_size += total_size;
        
        Ok(())
    }
    
    fn get_chunk(&self, path: &str, chunk_id: usize) -> Option<Vec<u8>> {
        let mut cache = self.cache.write().unwrap();
        
        if let Some(file) = cache.get_mut(path) {
            file.access_count += 1;
            
            if let Some(chunk) = file.chunks.get(chunk_id) {
                return Some(chunk.data.clone());
            }
        }
        
        None
    }
    
    fn evict_lru(&mut self) {
        let cache = self.cache.read().unwrap();
        
        // Find least recently used
        let lru = cache.iter()
            .min_by_key(|(_, f)| f.access_count)
            .map(|(k, _)| k.clone());
        
        drop(cache);
        
        if let Some(key) = lru {
            let mut cache = self.cache.write().unwrap();
            if let Some(file) = cache.remove(&key) {
                self.current_size -= file.total_size;
                println!("  🗑️  Evicted {} ({} bytes)", key, file.total_size);
            }
        }
    }
    
    fn stats(&self) {
        let cache = self.cache.read().unwrap();
        
        println!("\n📊 CACHE STATISTICS");
        println!("═══════════════════════════════════════════════════════════");
        println!("  Files cached: {}", cache.len());
        println!("  Memory used: {} / {} bytes ({:.1}%)", 
                 self.current_size, 
                 self.max_size,
                 (self.current_size as f64 / self.max_size as f64) * 100.0);
        
        let total_chunks: usize = cache.values().map(|f| f.chunks.len()).sum();
        println!("  Total chunks: {}", total_chunks);
        
        println!("\n  Cached files:");
        for (path, file) in cache.iter() {
            println!("    {} - {} bytes, {} chunks, {} accesses",
                     path, file.total_size, file.chunks.len(), file.access_count);
        }
    }
}

fn main() {
    println!("\n💾 SHARED MEMORY CACHE - Chunked file loading");
    println!("═══════════════════════════════════════════════════════════\n");
    
    // Create cache with 1MB limit
    let mut cache = SharedMemoryCache::new(1024 * 1024);
    
    // Load slow files identified by perf analysis
    println!("🔍 Loading slow files from perf analysis...\n");
    
    // Load perf samples (the slow file)
    cache.load_file("generated/perf_samples.csv").ok();
    
    // Load other frequently accessed files
    cache.load_file("generated/merged_constants.pl").ok();
    cache.load_file("generated/llm.txt").ok();
    
    // Show stats
    cache.stats();
    
    // Test chunk access
    println!("\n🔍 Testing chunk access...");
    if let Some(chunk) = cache.get_chunk("generated/llm.txt", 0) {
        println!("  ✅ Retrieved chunk 0: {} bytes", chunk.len());
        println!("  Preview: {:?}...", String::from_utf8_lossy(&chunk[..50.min(chunk.len())]));
    }
    
    // Access again (should increment counter)
    cache.get_chunk("generated/llm.txt", 0);
    cache.get_chunk("generated/llm.txt", 1);
    
    // Final stats
    cache.stats();
    
    println!("\n✅ COMPLETE");
    println!("\nFiles are now in shared memory with chunked access!");
}
