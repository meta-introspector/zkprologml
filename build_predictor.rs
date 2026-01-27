use std::fs;
use std::collections::HashMap;
use rayon::prelude::*;

#[derive(Debug, Clone)]
struct LatticePoint {
    chord: String,
    p: usize,
    n: usize,
    m: usize,
    ngram: Vec<u8>,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔮 Building Predictor & Resonator\n");
    
    // Load all lattice files
    let lattice_files: Vec<_> = fs::read_dir(".")?
        .filter_map(|e| e.ok())
        .filter(|e| e.file_name().to_string_lossy().ends_with("_lattice.txt"))
        .collect();
    
    let mut all_points: Vec<LatticePoint> = Vec::new();
    
    for entry in lattice_files {
        let path = entry.path();
        let chord = path.file_stem().unwrap().to_string_lossy()
            .replace("_lattice", "");
        
        if let Ok(content) = fs::read_to_string(&path) {
            for line in content.lines().skip(2) {
                if let Some(point) = parse_lattice_line(line, &chord) {
                    all_points.push(point);
                }
            }
        }
    }
    
    println!("📊 Loaded {} lattice points\n", all_points.len());
    
    // Build resonance groups
    let mut resonance_groups: HashMap<(usize, usize), Vec<LatticePoint>> = HashMap::new();
    
    for point in &all_points {
        resonance_groups.entry((point.p, point.n))
            .or_insert_with(Vec::new)
            .push(point.clone());
    }
    
    println!("🎵 Resonance Groups (P×N):");
    for ((p, n), points) in &resonance_groups {
        let mut chord_set = std::collections::HashSet::new();
        for pt in points {
            if let Some(chord_type) = pt.chord.split('_').next() {
                chord_set.insert(chord_type);
            }
        }
        println!("  P={} N={} → {} points across {} chord types", p, n, points.len(), chord_set.len());
    }
    
    // Build predictor: ngram → chord
    println!("\n🔮 Building Predictor:");
    let mut ngram_to_chords: HashMap<Vec<u8>, HashMap<String, usize>> = HashMap::new();
    
    for point in &all_points {
        let chord_type = point.chord.split('_').next().unwrap_or("").to_string();
        let entry = ngram_to_chords.entry(point.ngram.clone())
            .or_insert_with(HashMap::new);
        *entry.entry(chord_type).or_insert(0) += point.m;
    }
    
    // Find discriminative n-grams
    let mut discriminative: Vec<_> = ngram_to_chords.iter()
        .filter(|(_, chords)| chords.len() == 1)
        .map(|(ngram, chords)| {
            let (chord, &count) = chords.iter().next().unwrap();
            (ngram.clone(), chord.clone(), count)
        })
        .collect();
    
    discriminative.sort_by_key(|(_, _, count)| std::cmp::Reverse(*count));
    
    println!("  Found {} unique n-grams", ngram_to_chords.len());
    println!("  Found {} discriminative n-grams (single chord)", discriminative.len());
    
    // Save predictor
    let mut predictor_output = String::from("# Chord Predictor\n\n");
    for (ngram, chord, count) in discriminative.iter().take(100) {
        predictor_output.push_str(&format!("{:?} → {} (M={})\n", ngram, chord, count));
    }
    fs::write("chord_predictor.txt", predictor_output)?;
    
    // Build resonator: group by similarity
    println!("\n🎼 Building Resonator:");
    let mut chord_signatures: HashMap<String, Vec<(usize, usize, usize)>> = HashMap::new();
    
    for point in &all_points {
        let chord_type = point.chord.split('_').next().unwrap_or("").to_string();
        chord_signatures.entry(chord_type)
            .or_insert_with(Vec::new)
            .push((point.p, point.n, point.m));
    }
    
    let mut resonator_output = String::from("# Chord Resonator\n\n");
    for (chord, signature) in &chord_signatures {
        let avg_p: f64 = signature.iter().map(|(p, _, _)| *p as f64).sum::<f64>() / signature.len() as f64;
        let avg_n: f64 = signature.iter().map(|(_, n, _)| *n as f64).sum::<f64>() / signature.len() as f64;
        let avg_m: f64 = signature.iter().map(|(_, _, m)| *m as f64).sum::<f64>() / signature.len() as f64;
        
        resonator_output.push_str(&format!(
            "{}: P̄={:.2} N̄={:.2} M̄={:.2} (n={})\n",
            chord, avg_p, avg_n, avg_m, signature.len()
        ));
    }
    fs::write("chord_resonator.txt", resonator_output)?;
    
    println!("  Analyzed {} chord types", chord_signatures.len());
    println!("\n✅ Saved: chord_predictor.txt");
    println!("✅ Saved: chord_resonator.txt");
    
    Ok(())
}

fn parse_lattice_line(line: &str, chord: &str) -> Option<LatticePoint> {
    let parts: Vec<&str> = line.split_whitespace().collect();
    if parts.len() < 4 { return None; }
    
    let p = parts[0].strip_prefix("P=")?.parse().ok()?;
    let n = parts[1].strip_prefix("N=")?.parse().ok()?;
    let m = parts[2].strip_prefix("M=")?.parse().ok()?;
    
    let ngram_str = line.split("ngram=").nth(1)?;
    let ngram: Vec<u8> = ngram_str.trim_matches(|c| c == '[' || c == ']')
        .split(", ")
        .filter_map(|s| s.parse().ok())
        .collect();
    
    Some(LatticePoint {
        chord: chord.to_string(),
        p, n, m, ngram,
    })
}
