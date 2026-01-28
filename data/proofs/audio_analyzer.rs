// Apply audio model to waveforms - extract features and map to primes

use std::fs::File;
use std::io::Read;
use std::path::Path;

// WAV header structure (44 bytes)
#[repr(C, packed)]
struct WavHeader {
    riff: [u8; 4],
    size: u32,
    wave: [u8; 4],
    fmt: [u8; 4],
    fmt_size: u32,
    audio_format: u16,
    num_channels: u16,
    sample_rate: u32,
    byte_rate: u32,
    block_align: u16,
    bits_per_sample: u16,
    data: [u8; 4],
    data_size: u32,
}

// Audio features extracted from waveform
#[derive(Debug)]
struct AudioFeatures {
    rms: f32,           // Root mean square (energy)
    zero_crossings: u32, // Zero crossing rate
    peak: i16,          // Peak amplitude
    spectral_centroid: f32, // Frequency center
}

impl AudioFeatures {
    // Map features to prime signature
    fn to_prime_signature(&self) -> Vec<u64> {
        let mut primes = Vec::new();
        
        // Energy → primes 2, 3, 5
        if self.rms > 10000.0 { primes.push(2); }
        if self.rms > 15000.0 { primes.push(3); }
        if self.rms > 20000.0 { primes.push(5); }
        
        // Zero crossings → primes 7, 11
        if self.zero_crossings > 1000 { primes.push(7); }
        if self.zero_crossings > 2000 { primes.push(11); }
        
        // Peak → primes 13, 17
        if self.peak > 20000 { primes.push(13); }
        if self.peak > 25000 { primes.push(17); }
        
        // Spectral → primes 19, 23
        if self.spectral_centroid > 500.0 { primes.push(19); }
        if self.spectral_centroid > 1000.0 { primes.push(23); }
        
        primes
    }
}

// Load WAV file and extract samples
fn load_wav(path: &Path) -> Result<Vec<i16>, Box<dyn std::error::Error>> {
    let mut file = File::open(path)?;
    
    // Skip header (44 bytes)
    let mut header = [0u8; 44];
    file.read_exact(&mut header)?;
    
    // Read samples
    let mut samples = Vec::new();
    let mut buf = [0u8; 2];
    
    while file.read_exact(&mut buf).is_ok() {
        let sample = i16::from_le_bytes(buf);
        samples.push(sample);
    }
    
    Ok(samples)
}

// Extract audio features from samples
fn extract_features(samples: &[i16]) -> AudioFeatures {
    // RMS (energy)
    let sum_squares: f64 = samples.iter()
        .map(|&s| (s as f64).powi(2))
        .sum();
    let rms = (sum_squares / samples.len() as f64).sqrt() as f32;
    
    // Zero crossings
    let zero_crossings = samples.windows(2)
        .filter(|w| (w[0] > 0 && w[1] < 0) || (w[0] < 0 && w[1] > 0))
        .count() as u32;
    
    // Peak amplitude
    let peak = samples.iter()
        .map(|&s| s.abs())
        .max()
        .unwrap_or(0);
    
    // Spectral centroid (simplified)
    let spectral_centroid = (zero_crossings as f32 * 44100.0) / (2.0 * samples.len() as f32);
    
    AudioFeatures {
        rms,
        zero_crossings,
        peak,
        spectral_centroid,
    }
}

// Process all audio files
fn process_audio_files() -> Result<(), Box<dyn std::error::Error>> {
    let audio_dir = Path::new("generated/audio");
    
    println!("🎵 Processing audio files...\n");
    
    let mut csv = String::from("file,rms,zero_crossings,peak,spectral_centroid,primes\n");
    
    for entry in std::fs::read_dir(audio_dir)? {
        let entry = entry?;
        let path = entry.path();
        
        if path.extension().and_then(|s| s.to_str()) == Some("wav") {
            let filename = path.file_name().unwrap().to_str().unwrap();
            
            match load_wav(&path) {
                Ok(samples) => {
                    let features = extract_features(&samples);
                    let primes = features.to_prime_signature();
                    
                    println!("♪ {}", filename);
                    println!("  RMS: {:.1}, ZC: {}, Peak: {}", 
                             features.rms, features.zero_crossings, features.peak);
                    println!("  Primes: {:?}", primes);
                    println!();
                    
                    // Add to CSV
                    csv.push_str(&format!("{},{:.1},{},{},{:.1},\"{:?}\"\n",
                        filename, features.rms, features.zero_crossings, 
                        features.peak, features.spectral_centroid, primes));
                }
                Err(e) => eprintln!("Error loading {}: {}", filename, e),
            }
        }
    }
    
    // Write CSV
    std::fs::write("generated/audio_features.csv", csv)?;
    println!("✅ Features saved to generated/audio_features.csv");
    
    Ok(())
}

fn main() {
    println!("\n🎼 AUDIO MODEL ANALYZER\n");
    println!("═══════════════════════════════════════════════════════════\n");
    
    if let Err(e) = process_audio_files() {
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }
    
    println!("✨ Audio analysis complete!\n");
}
