use std::fs;
use std::path::Path;
use goblin::Object;

// Analyze OCaml/opam perf traces and label bytes with Monster primes

const MONSTER_PRIMES: [usize; 15] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71];

fn is_monster_prime(n: usize) -> bool {
    MONSTER_PRIMES.contains(&n)
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔬 Analyzing OCaml/opam perf traces\n");
    
    let trace_dir = std::env::args().nth(1).unwrap_or_else(|| ".".to_string());
    
    // Analyze OCaml compiler binary
    analyze_binary("/nix/store/*/bin/ocamlc", "OCaml Compiler")?;
    analyze_binary("/nix/store/*/bin/opam", "OPAM")?;
    
    // Parse perf traces
    parse_perf_trace(&format!("{}/ocaml_compile.txt", trace_dir), "OCaml Compile")?;
    parse_perf_trace(&format!("{}/opam_list.txt", trace_dir), "OPAM List")?;
    
    Ok(())
}

fn analyze_binary(pattern: &str, name: &str) -> Result<(), Box<dyn std::error::Error>> {
    println!("📦 Analyzing {} binary...", name);
    
    // Find binary via glob pattern
    let paths: Vec<_> = glob::glob(pattern)
        .ok()
        .and_then(|g| g.collect::<Result<Vec<_>, _>>().ok())
        .unwrap_or_default();
    
    if let Some(path) = paths.first() {
        let buffer = fs::read(path)?;
        
        match Object::parse(&buffer)? {
            Object::Elf(elf) => {
                println!("  Sections: {}", elf.section_headers.len());
                println!("  Symbols: {}", elf.syms.len());
                
                // Label bytes with Monster primes
                let mut monster_bytes = 0;
                for (i, &byte) in buffer.iter().enumerate().take(1000) {
                    if is_monster_prime(byte as usize) {
                        monster_bytes += 1;
                        if monster_bytes <= 5 {
                            println!("  🔱 Byte {}: {} (Monster prime)", i, byte);
                        }
                    }
                }
                println!("  Total Monster bytes: {}/{}", monster_bytes, 1000);
                
                // Find hot symbols
                let mut hot_syms = Vec::new();
                for sym in elf.syms.iter().take(20) {
                    if let Some(name) = elf.strtab.get_at(sym.st_name) {
                        if !name.is_empty() {
                            hot_syms.push((name, sym.st_value, sym.st_size));
                        }
                    }
                }
                
                println!("  Hot symbols:");
                for (name, addr, size) in hot_syms.iter().take(5) {
                    println!("    {} @ 0x{:x} ({})", name, addr, size);
                }
            }
            _ => println!("  ⚠️  Not an ELF binary"),
        }
    } else {
        println!("  ⚠️  Binary not found: {}", pattern);
    }
    
    println!();
    Ok(())
}

fn parse_perf_trace(path: &str, name: &str) -> Result<(), Box<dyn std::error::Error>> {
    if !Path::new(path).exists() {
        println!("⚠️  Trace not found: {}", path);
        return Ok(());
    }
    
    println!("📊 Parsing {} trace...", name);
    
    let content = fs::read_to_string(path)?;
    let lines: Vec<_> = content.lines().take(10).collect();
    
    println!("  Lines: {}", content.lines().count());
    println!("  Sample:");
    for line in lines {
        println!("    {}", line);
    }
    
    println!();
    Ok(())
}
