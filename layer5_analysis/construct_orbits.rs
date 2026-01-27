use std::fs;
use std::collections::HashMap;

// Construct orbit for each byte in perf traces

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🌌 Constructing Orbits from Perf Trace Bytes\n");
    
    // Layer 0 actual trace values
    let cycles = 1_346_185u64;
    let instructions = 1_782_482u64;
    let cache_misses = 5_339u64;
    
    // Convert to bytes
    let mut all_bytes = Vec::new();
    all_bytes.extend_from_slice(&cycles.to_le_bytes());
    all_bytes.extend_from_slice(&instructions.to_le_bytes());
    all_bytes.extend_from_slice(&cache_misses.to_le_bytes());
    
    println!("📊 Trace bytes: {} total\n", all_bytes.len());
    
    // Construct orbit for each byte
    let mut orbits = HashMap::new();
    
    for (i, &byte) in all_bytes.iter().enumerate() {
        let orbit = construct_orbit(byte);
        orbits.insert(i, orbit);
        
        if i < 5 || i >= all_bytes.len() - 3 {
            println!("Byte {}: {} → orbit length {}", i, byte, orbits[&i].len());
        } else if i == 5 {
            println!("...");
        }
    }
    
    // Generate report
    let mut report = String::from("# Perf Trace Byte Orbits\n\n");
    report.push_str("## Layer 0 Trace Analysis\n\n");
    report.push_str(&format!("- Cycles: {}\n", cycles));
    report.push_str(&format!("- Instructions: {}\n", instructions));
    report.push_str(&format!("- Cache misses: {}\n\n", cache_misses));
    
    report.push_str(&format!("## Byte Orbits ({})\n\n", all_bytes.len()));
    report.push_str("| Byte # | Value | Orbit Length | Cycle |\n");
    report.push_str("|--------|-------|--------------|-------|\n");
    
    for i in 0..all_bytes.len() {
        let byte = all_bytes[i];
        let orbit = &orbits[&i];
        let cycle = if orbit.len() > 0 { orbit[orbit.len()-1] } else { byte };
        report.push_str(&format!("| {} | {} | {} | {} |\n", i, byte, orbit.len(), cycle));
    }
    
    report.push_str("\n## Orbit Statistics\n\n");
    let total_orbit_length: usize = orbits.values().map(|o| o.len()).sum();
    let avg_orbit = total_orbit_length as f64 / orbits.len() as f64;
    report.push_str(&format!("- Total orbit length: {}\n", total_orbit_length));
    report.push_str(&format!("- Average orbit: {:.2}\n", avg_orbit));
    
    // Find fixed points (orbit length 1)
    let fixed: Vec<_> = orbits.iter()
        .filter(|(_, o)| o.len() == 1)
        .map(|(i, _)| (*i, all_bytes[*i]))
        .collect();
    
    report.push_str(&format!("- Fixed points: {}\n\n", fixed.len()));
    
    report.push_str("## Monster Prime Resonance\n\n");
    for (i, byte) in all_bytes.iter().enumerate() {
        if is_monster_prime(*byte as usize) {
            report.push_str(&format!("- Byte {}: {} 🔱 MONSTER\n", i, byte));
        }
    }
    
    fs::write("perf_trace_orbits.md", report)?;
    println!("\n✅ Saved: perf_trace_orbits.md");
    
    Ok(())
}

fn construct_orbit(byte: u8) -> Vec<u8> {
    let mut orbit = Vec::new();
    let mut current = byte;
    let mut seen = std::collections::HashSet::new();
    
    // Orbit under f(x) = (x * 3 + 1) mod 256
    while !seen.contains(&current) {
        seen.insert(current);
        orbit.push(current);
        current = ((current as u16 * 3 + 1) % 256) as u8;
    }
    
    orbit
}

fn is_monster_prime(n: usize) -> bool {
    [2,3,5,7,11,13,17,19,23,29,31,41,47,59,71].contains(&n)
}
