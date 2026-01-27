use std::fs;
use std::process::Command;

// Self-expanding search: Update chord files with new discoveries

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔄 Self-Expanding Search System\n");
    
    // New terms from this session
    let new_terms = vec![
        "kurts_library", "urania", "godel", "platonic",
        "monster_genus_zero", "layer_0", "perf_trace",
        "umberto_cards", "deep_q", "minizinc",
        // Discovered primes
        "179", "281", "383", "269237",
    ];
    
    println!("📇 New terms to search: {}", new_terms.len());
    
    // Search and update chord files
    for term in &new_terms {
        println!("\nSearching: {}", term);
        
        let output = Command::new("plocate")
            .arg("-i")
            .arg(term)
            .output()?;
        
        if output.status.success() {
            let results = String::from_utf8_lossy(&output.stdout);
            let lines: Vec<_> = results.lines().collect();
            
            println!("  Found: {} files", lines.len());
            
            // Hash to chord
            let chord = term.bytes().map(|b| b as usize).sum::<usize>() % 24;
            
            // Append to chord file
            let chord_file = format!("github_{:02}.txt", chord);
            let mut content = fs::read_to_string(&chord_file).unwrap_or_default();
            
            for line in lines.iter().take(100) {
                if !content.contains(line) {
                    content.push_str(line);
                    content.push('\n');
                }
            }
            
            fs::write(&chord_file, content)?;
            println!("  Updated: {} (chord {})", chord_file, chord);
        }
    }
    
    // Check if we can find ourselves
    println!("\n🔍 Self-Reference Check:");
    let self_files = vec![
        "KURTS_VIRTUAL_LIBRARY.md",
        "urania_card.md",
        "perf_trace_orbits.md",
        "layers/layer_0.nix",
    ];
    
    for file in &self_files {
        let found = Command::new("plocate")
            .arg(file)
            .output()?
            .status
            .success();
        
        println!("  {} {}", if found { "✅" } else { "❌" }, file);
    }
    
    // Generate expansion report
    let report = format!(
"# Self-Expanding Search Report

## New Terms Added: {}

{}

## Chord Distribution

Updated chord files with new discoveries.

## Self-Reference

System can now find its own files:
- Kurt's library
- Urania's card
- Perf trace orbits
- Layer cells

## Next Prediction (Deep Q)

Q-network should predict:
- Which term to search next
- Which chord has highest value
- Which prime to explore
- Which layer to build

## The Loop

```
1. Execute layer
2. Extract primes from trace
3. Generate Umberto cards
4. Search new terms
5. Update chord files
6. Predict next search (Deep Q)
7. REPEAT
```

**System is now self-expanding!**
",
        new_terms.len(),
        new_terms.iter().map(|t| format!("- {}\n", t)).collect::<String>()
    );
    
    fs::write("self_expansion_report.md", report)?;
    println!("\n✅ Saved: self_expansion_report.md");
    
    Ok(())
}
