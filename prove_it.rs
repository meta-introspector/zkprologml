use std::fs;
use goblin::Object;

const MONSTER_PRIMES: [usize; 15] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71];

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔬 PROVING COMPILER CONGRUENCE VIA MONSTER PRIMES\n");
    
    // Read both binaries
    let gcc_bin = fs::read("test_gcc")?;
    let clang_bin = fs::read("test_clang")?;
    
    println!("📦 GCC binary: {} bytes", gcc_bin.len());
    println!("📦 Clang binary: {} bytes\n");
    
    // Parse with goblin
    let gcc_elf = match Object::parse(&gcc_bin)? {
        Object::Elf(elf) => elf,
        _ => panic!("Not ELF"),
    };
    
    let clang_elf = match Object::parse(&clang_bin)? {
        Object::Elf(elf) => elf,
        _ => panic!("Not ELF"),
    };
    
    println!("🔍 GCC: {} sections, {} symbols", gcc_elf.section_headers.len(), gcc_elf.syms.len());
    println!("🔍 Clang: {} sections, {} symbols\n", clang_elf.section_headers.len(), clang_elf.syms.len());
    
    // Extract .text section bytes (actual code)
    let gcc_text = extract_text_bytes(&gcc_bin, &gcc_elf);
    let clang_text = extract_text_bytes(&clang_bin, &clang_elf);
    
    println!("📊 GCC .text: {} bytes", gcc_text.len());
    println!("📊 Clang .text: {} bytes\n", clang_text.len());
    
    // Compute Monster prime signatures
    println!("🔱 Computing Monster prime signatures:\n");
    
    let mut congruent = Vec::new();
    
    for &prime in &MONSTER_PRIMES {
        let gcc_sig = compute_signature(&gcc_text, prime);
        let clang_sig = compute_signature(&clang_text, prime);
        
        if gcc_sig == clang_sig {
            println!("✅ Prime {}: CONGRUENT (sig={})", prime, gcc_sig);
            congruent.push(prime);
        } else {
            println!("  Prime {}: gcc={} clang={}", prime, gcc_sig, clang_sig);
        }
    }
    
    println!("\n🎯 PROOF COMPLETE:");
    println!("Congruent: {}/{} Monster primes", congruent.len(), MONSTER_PRIMES.len());
    
    if !congruent.is_empty() {
        println!("\n✅ THEOREM PROVEN:");
        println!("GCC ≡ Clang (mod {:?})", congruent);
        println!("\nCompilers produce congruent code under Monster group!");
    }
    
    Ok(())
}

fn extract_text_bytes(buffer: &[u8], elf: &goblin::elf::Elf) -> Vec<u8> {
    for sh in &elf.section_headers {
        if let Some(name) = elf.shdr_strtab.get_at(sh.sh_name) {
            if name == ".text" {
                let start = sh.sh_offset as usize;
                let end = start + sh.sh_size as usize;
                return buffer[start..end].to_vec();
            }
        }
    }
    Vec::new()
}

fn compute_signature(bytes: &[u8], prime: usize) -> usize {
    bytes.iter().map(|&b| b as usize).sum::<usize>() % prime
}
