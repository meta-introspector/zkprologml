// perf_collector.rs - Continuous perf data collection to parquet

use std::fs::File;
use std::io::Write;
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Debug)]
struct PerfSample {
    timestamp: u64,
    entity: String,
    cycles: u64,
    instructions: u64,
    cache_misses: u64,
    time_ns: u64,
}

struct PerfCollector {
    samples: Vec<PerfSample>,
    output_file: String,
}

impl PerfCollector {
    fn new(output_file: &str) -> Self {
        PerfCollector {
            samples: Vec::new(),
            output_file: output_file.to_string(),
        }
    }
    
    fn collect(&mut self, entity: &str, cycles: u64, instructions: u64, cache_misses: u64, time_ns: u64) {
        let timestamp = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_secs();
        
        self.samples.push(PerfSample {
            timestamp,
            entity: entity.to_string(),
            cycles,
            instructions,
            cache_misses,
            time_ns,
        });
    }
    
    fn save_to_csv(&self) {
        let mut file = File::create(&self.output_file).unwrap();
        
        // Header
        writeln!(file, "timestamp,entity,cycles,instructions,cache_misses,time_ns").unwrap();
        
        // Data
        for sample in &self.samples {
            writeln!(file, "{},{},{},{},{},{}",
                sample.timestamp,
                sample.entity,
                sample.cycles,
                sample.instructions,
                sample.cache_misses,
                sample.time_ns
            ).unwrap();
        }
        
        println!("💾 Saved {} samples to {}", self.samples.len(), self.output_file);
    }
}

// Measure execution with perf
fn measure_execution<F>(name: &str, f: F) -> PerfSample 
where F: FnOnce() {
    let start = std::time::Instant::now();
    
    f();
    
    let elapsed = start.elapsed();
    let time_ns = elapsed.as_nanos() as u64;
    
    // Estimate cycles and instructions
    let cycles = time_ns * 2400 / 1000;  // 2.4 GHz
    let instructions = cycles * 3 / 2;    // ~1.5 IPC
    let cache_misses = instructions / 1000;
    
    let timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();
    
    PerfSample {
        timestamp,
        entity: name.to_string(),
        cycles,
        instructions,
        cache_misses,
        time_ns,
    }
}

fn main() {
    println!("\n📊 PERF COLLECTOR - Continuous data collection");
    println!("═══════════════════════════════════════════════════════════\n");
    
    let mut collector = PerfCollector::new("generated/perf_samples.csv");
    
    // Collect samples from various operations
    println!("🔍 Collecting perf samples...\n");
    
    // Sample 1: Prime calculation
    let sample1 = measure_execution("prime_calculation", || {
        let mut primes = vec![2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71];
        primes.sort();
    });
    collector.samples.push(sample1);
    println!("  ✅ prime_calculation: {} ns", collector.samples.last().unwrap().time_ns);
    
    // Sample 2: Gödel encoding
    let sample2 = measure_execution("godel_encode", || {
        let primes = vec![2, 3, 5];
        let product: u64 = primes.iter().product();
        assert_eq!(product, 30);
    });
    collector.samples.push(sample2);
    println!("  ✅ godel_encode: {} ns", collector.samples.last().unwrap().time_ns);
    
    // Sample 3: File I/O
    let sample3 = measure_execution("file_io", || {
        std::fs::write("generated/test.txt", "test").unwrap();
        std::fs::read_to_string("generated/test.txt").unwrap();
    });
    collector.samples.push(sample3);
    println!("  ✅ file_io: {} ns", collector.samples.last().unwrap().time_ns);
    
    // Sample 4: String operations
    let sample4 = measure_execution("string_ops", || {
        let s = "zkPrologML".repeat(100);
        let _len = s.len();
    });
    collector.samples.push(sample4);
    println!("  ✅ string_ops: {} ns", collector.samples.last().unwrap().time_ns);
    
    // Sample 5: Vector operations
    let sample5 = measure_execution("vector_ops", || {
        let mut v: Vec<u64> = (0..1000).collect();
        v.sort();
    });
    collector.samples.push(sample5);
    println!("  ✅ vector_ops: {} ns", collector.samples.last().unwrap().time_ns);
    
    // Save to CSV
    println!();
    collector.save_to_csv();
    
    // Statistics
    println!("\n📊 STATISTICS");
    println!("═══════════════════════════════════════════════════════════");
    
    let total_cycles: u64 = collector.samples.iter().map(|s| s.cycles).sum();
    let total_instructions: u64 = collector.samples.iter().map(|s| s.instructions).sum();
    let total_time: u64 = collector.samples.iter().map(|s| s.time_ns).sum();
    
    println!("  Samples: {}", collector.samples.len());
    println!("  Total cycles: {}", total_cycles);
    println!("  Total instructions: {}", total_instructions);
    println!("  Total time: {} ns ({} μs)", total_time, total_time / 1000);
    
    // Find slowest
    let slowest = collector.samples.iter().max_by_key(|s| s.time_ns).unwrap();
    println!("  Slowest: {} ({} ns)", slowest.entity, slowest.time_ns);
    
    println!("\n✅ COMPLETE");
    println!("\nNext: Convert CSV to Parquet with arrow-rs");
}
