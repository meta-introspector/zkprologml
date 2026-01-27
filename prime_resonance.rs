use std::fs;
use std::io::Read;
use rayon::prelude::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let primes = vec![2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47];
    
    println!("🎵 Sampling content at prime intervals: {:?}\n", primes);
    
    // Get all chord files
    let chord_files: Vec<_> = fs::read_dir(".")?
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().map(|s| s == "txt").unwrap_or(false))
        .filter(|e| e.file_name().to_string_lossy().contains("_"))
        .collect();
    
    chord_files.par_iter().for_each(|entry| {
        let chord_file = entry.path();
        let chord_name = chord_file.file_stem().unwrap().to_string_lossy().to_string();
        
        if let Ok(content) = fs::read_to_string(&chord_file) {
            let paths: Vec<_> = content.lines().collect();
            
            let mut resonances = vec![0u64; primes.len()];
            let mut samples = Vec::new();
            
            for path in paths {
                if let Ok(mut file) = fs::File::open(path) {
                    let mut buffer = Vec::new();
                    if file.read_to_end(&mut buffer).is_ok() {
                        // Sample at prime positions
                        for (i, &prime) in primes.iter().enumerate() {
                            let mut hash = 0u64;
                            for pos in (0..buffer.len()).step_by(prime) {
                                hash = hash.wrapping_add(buffer[pos] as u64);
                            }
                            resonances[i] = resonances[i].wrapping_add(hash);
                        }
                        
                        // Store sample
                        if buffer.len() > 100 {
                            samples.push(format!("{}: {} bytes", path, buffer.len()));
                        }
                    }
                }
            }
            
            // Find dominant prime (resonance)
            if let Some((idx, &max_res)) = resonances.iter().enumerate().max_by_key(|(_, &v)| v) {
                println!("🎼 {} → prime {} resonance: {}", chord_name, primes[idx], max_res);
                
                // Save resonance profile
                let profile = format!(
                    "chord: {}\nresonances: {:?}\nsamples: {}\n",
                    chord_name,
                    resonances,
                    samples.len()
                );
                let _ = fs::write(format!("{}_resonance.txt", chord_name), profile);
            }
        }
    });
    
    Ok(())
}
