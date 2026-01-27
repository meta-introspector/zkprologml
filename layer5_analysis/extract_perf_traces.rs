use std::fs;
use std::collections::HashSet;

const MONSTER_PRIMES: [usize; 15] = [2,3,5,7,11,13,17,19,23,29,31,41,47,59,71];

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔍 Extracting Primes & Constants from Perf Traces\n");
    
    let mut discovered_primes = HashSet::new();
    let mut discovered_constants = HashSet::new();
    let mut new_cards = Vec::new();
    
    // Extract from layer 0 actual trace
    println!("📊 Analyzing Layer 0 trace:");
    let layer0_cycles = 1_346_185;
    let layer0_inst = 1_782_482;
    let layer0_cache = 5_339;
    
    println!("   Cycles: {}", layer0_cycles);
    println!("   Instructions: {}", layer0_inst);
    println!("   Cache misses: {}", layer0_cache);
    
    // Extract primes from values
    extract_primes(layer0_cycles, &mut discovered_primes);
    extract_primes(layer0_inst, &mut discovered_primes);
    extract_primes(layer0_cache, &mut discovered_primes);
    
    // Extract constants (ratios, patterns)
    let ipc = layer0_inst as f64 / layer0_cycles as f64;
    let cache_ratio = layer0_cache as f64 / layer0_cycles as f64;
    
    discovered_constants.insert((ipc * 1000.0) as usize); // IPC × 1000
    discovered_constants.insert((cache_ratio * 1000000.0) as usize); // Cache ratio × 1M
    
    println!("\n🔢 Discovered primes: {:?}", discovered_primes.iter().take(10).collect::<Vec<_>>());
    println!("📐 Discovered constants: {:?}", discovered_constants.iter().take(5).collect::<Vec<_>>());
    
    // Generate new Umberto cards from discoveries
    println!("\n📇 Generating new Umberto cards...");
    
    for prime in &discovered_primes {
        if *prime < 1000 {  // Reasonable primes
            let chord = prime % 24;
            new_cards.push(format!(
                "**Card {}**: Prime {} from perf trace (Chord: {})",
                new_cards.len(), prime, chord
            ));
        }
    }
    
    for constant in &discovered_constants {
        let chord = constant % 24;
        new_cards.push(format!(
            "**Card {}**: Constant {} from trace ratio (Chord: {})",
            new_cards.len(), constant, chord
        ));
    }
    
    // Check for Monster prime resonance
    println!("\n🔱 Monster Prime Resonance:");
    for prime in &discovered_primes {
        if MONSTER_PRIMES.contains(prime) {
            println!("   ✅ {} is a Monster prime!", prime);
        }
    }
    
    // Generate report
    let mut report = String::from("# Perf Trace Extraction Report\n\n");
    report.push_str("## Source: Layer 0 Actual Trace\n\n");
    report.push_str(&format!("- Cycles: {}\n", layer0_cycles));
    report.push_str(&format!("- Instructions: {}\n", layer0_inst));
    report.push_str(&format!("- Cache misses: {}\n", layer0_cache));
    report.push_str(&format!("- IPC: {:.3}\n\n", ipc));
    
    report.push_str(&format!("## Discovered Primes ({})\n\n", discovered_primes.len()));
    let mut primes_vec: Vec<_> = discovered_primes.iter().collect();
    primes_vec.sort();
    for prime in primes_vec.iter().take(20) {
        let is_monster = if MONSTER_PRIMES.contains(prime) { " 🔱 MONSTER" } else { "" };
        report.push_str(&format!("- {}{}\n", prime, is_monster));
    }
    
    report.push_str(&format!("\n## Discovered Constants ({})\n\n", discovered_constants.len()));
    let mut constants_vec: Vec<_> = discovered_constants.iter().collect();
    constants_vec.sort();
    for constant in constants_vec.iter().take(10) {
        report.push_str(&format!("- {}\n", constant));
    }
    
    report.push_str(&format!("\n## New Umberto Cards ({})\n\n", new_cards.len()));
    for card in &new_cards {
        report.push_str(&format!("{}\n", card));
    }
    
    report.push_str("\n## Integration with Card System\n\n");
    report.push_str("These discoveries will be:\n");
    report.push_str("1. Added to Umberto's index cards\n");
    report.push_str("2. Hashed to harmonic chords (mod 24)\n");
    report.push_str("3. Searched in existing repos\n");
    report.push_str("4. Combined with LMFDB terms\n");
    report.push_str("5. Used for self-expansion\n\n");
    
    report.push_str("## Next Iteration\n\n");
    report.push_str("Extract from all 72 layers:\n");
    report.push_str("- Build all layers\n");
    report.push_str("- Capture all perf traces\n");
    report.push_str("- Extract all primes/constants\n");
    report.push_str("- Generate complete card set\n");
    report.push_str("- Search for resonances\n");
    
    fs::write("perf_trace_extraction.md", report)?;
    println!("\n✅ Saved: perf_trace_extraction.md");
    
    // Append to Umberto's cards
    append_to_umberto_cards(&new_cards)?;
    
    Ok(())
}

fn extract_primes(n: usize, primes: &mut HashSet<usize>) {
    let mut num = n;
    let mut d = 2;
    
    while d * d <= num {
        while num % d == 0 {
            primes.insert(d);
            num /= d;
        }
        d += 1;
    }
    
    if num > 1 {
        primes.insert(num);
    }
}

fn append_to_umberto_cards(new_cards: &[String]) -> Result<(), Box<dyn std::error::Error>> {
    let mut content = String::from("\n\n# New Cards from Perf Trace Extraction\n\n");
    content.push_str(&format!("Generated: {} cards\n\n", new_cards.len()));
    
    for card in new_cards {
        content.push_str(&format!("{}\n", card));
    }
    
    // Append to existing cards
    if let Ok(existing) = fs::read_to_string("umberto_index_cards.md") {
        fs::write("umberto_index_cards.md", format!("{}{}", existing, content))?;
        println!("✅ Appended {} cards to umberto_index_cards.md", new_cards.len());
    } else {
        fs::write("umberto_perf_cards.md", content)?;
        println!("✅ Created umberto_perf_cards.md with {} cards", new_cards.len());
    }
    
    Ok(())
}
