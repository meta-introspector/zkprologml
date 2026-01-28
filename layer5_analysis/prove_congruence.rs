use std::fs;

// Prove congruence: parse perf traces and output Prolog facts

const MONSTER_PRIMES: [u64; 15] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71];

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔬 Computing trace congruence mod Monster primes\n");
    
    // Parse metrics
    let metrics = fs::read_to_string("test_metrics.txt")?;
    let mut compilers = Vec::new();
    
    for line in metrics.lines() {
        if line.is_empty() { continue; }
        let parts: Vec<_> = line.split(':').collect();
        if parts.len() != 2 { continue; }
        
        let compiler = parts[0].trim();
        let rest = parts[1];
        
        let mut cycles = 0u64;
        let mut insns = 0u64;
        
        for part in rest.split_whitespace() {
            if let Some(val) = part.strip_prefix("cycles=") {
                cycles = val.parse().unwrap_or(0);
            }
            if let Some(val) = part.strip_prefix("insns=") {
                insns = val.parse().unwrap_or(0);
            }
        }
        
        compilers.push((compiler.to_string(), cycles, insns));
        println!("{}: cycles={} insns={}", compiler, cycles, insns);
    }
    
    println!("\n🔍 Checking congruence mod Monster primes:\n");
    
    // Check congruence for each prime
    let mut congruent_primes = Vec::new();
    
    for &prime in &MONSTER_PRIMES {
        let mods: Vec<_> = compilers.iter()
            .map(|(name, cycles, insns)| {
                (name.clone(), cycles % prime, insns % prime)
            })
            .collect();
        
        // Check if all have same mod
        let all_same = mods.windows(2).all(|w| {
            w[0].1 == w[1].1 && w[0].2 == w[1].2
        });
        
        if all_same {
            println!("✅ Prime {}: CONGRUENT", prime);
            congruent_primes.push(prime);
        } else {
            println!("  Prime {}: {}", prime, 
                mods.iter().map(|(n, c, i)| format!("{}({},{})", n, c, i))
                    .collect::<Vec<_>>().join(" "));
        }
    }
    
    println!("\n📊 Results:");
    println!("Congruent primes: {}/{}", congruent_primes.len(), MONSTER_PRIMES.len());
    println!("Primes: {:?}", congruent_primes);
    
    // Output Prolog facts
    println!("\n📤 Generating Prolog facts...");
    let mut prolog = String::new();
    
    prolog.push_str("% Compiler trace metrics\n");
    for (name, cycles, insns) in &compilers {
        prolog.push_str(&format!("trace({}, cycles, {}).\n", name, cycles));
        prolog.push_str(&format!("trace({}, insns, {}).\n", name, insns));
    }
    
    prolog.push_str("\n% Congruence mod Monster primes\n");
    for &prime in &congruent_primes {
        prolog.push_str(&format!("congruent_mod({}).\n", prime));
    }
    
    prolog.push_str("\n% Theorem: Compilers are congruent\n");
    prolog.push_str(&format!("theorem(compiler_congruence, {}).\n", congruent_primes.len()));
    
    fs::write("congruence.pl", prolog)?;
    println!("✅ Written: congruence.pl");
    
    Ok(())
}
