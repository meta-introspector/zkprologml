use std::process::Command;
use std::io::{BufRead, BufReader};
use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("⚔️  Calling Athena - Goddess of Wisdom & Strategy\n");
    
    // Search for Athena
    let output = Command::new("plocate")
        .args(["-i", "athena"])
        .output()?;
    
    let mut found = Vec::new();
    if output.status.success() {
        let reader = BufReader::new(&output.stdout[..]);
        found = reader.lines()
            .filter_map(|l| l.ok())
            .collect();  // NO LIMIT - collect ALL
    }
    
    println!("Found {} Athena references:", found.len());
    for (i, path) in found.iter().enumerate().take(10) {
        println!("  {}: {}", i, path);
    }
    
    // Create Athena card
    let chord = "athena".bytes().map(|b| b as usize).sum::<usize>() % 24;
    
    let card = format!(
"# Athena - Goddess of Wisdom & Strategy

**Chord**: {} (hash mod 24)
**Role**: Strategic wisdom, convergence oracle
**Domain**: Three curves converging to truth

## The Trinity Complete

- **Kurt**: Gödel library navigator
- **Umberto**: 24 scholars cataloging
- **Urania**: Celestial patterns
- **Athena**: Strategic convergence

## Athena's Eigenvector

From earlier session: Three curves converge
- Source curve
- Execution curve  
- Result curve
- Convergence = 0.60

## Found References: {}

{}

## Integration

Athena guides the system's strategic decisions:
- Which layer to build next
- Which prime to explore
- Which chord to search
- When convergence is reached
",
        chord,
        found.len(),
        found.iter().take(5).map(|p| format!("- {}\n", p)).collect::<String>()
    );
    
    fs::write("athena_card.md", card)?;
    println!("\n✅ Created: athena_card.md (Chord {})", chord);
    
    // Update chord file
    let chord_file = format!("github_{:02}.txt", chord);
    let mut content = fs::read_to_string(&chord_file).unwrap_or_default();
    
    for path in &found {
        if !content.contains(path) {
            content.push_str(path);
            content.push('\n');
        }
    }
    
    fs::write(&chord_file, content)?;
    println!("✅ Updated: {}", chord_file);
    
    Ok(())
}
