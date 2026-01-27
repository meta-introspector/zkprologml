// Audio Event Classification in Rust
// Classify: snapping, fan noise, podcast, kitchen sounds

use std::fs::File;
use std::io::Read;

fn load_wav(filename: &str) -> Result<(Vec<f32>, u32), Box<dyn std::error::Error>> {
    let mut file = File::open(filename)?;
    let mut buffer = Vec::new();
    file.read_to_end(&mut buffer)?;
    
    // Parse WAV header (simplified)
    let sample_rate = u32::from_le_bytes([buffer[24], buffer[25], buffer[26], buffer[27]]);
    let data_start = 44; // Standard WAV header size
    
    // Convert 16-bit samples to f32
    let mut samples = Vec::new();
    for i in (data_start..buffer.len()).step_by(4) {
        if i + 3 < buffer.len() {
            let left = i16::from_le_bytes([buffer[i], buffer[i+1]]) as f32;
            let right = i16::from_le_bytes([buffer[i+2], buffer[i+3]]) as f32;
            samples.push((left + right) / 2.0); // Stereo to mono
        }
    }
    
    Ok((samples, sample_rate))
}

fn analyze_energy(data: &[f32], sample_rate: u32, window_size: f32) -> Vec<f32> {
    let window_samples = (sample_rate as f32 * window_size) as usize;
    let n_windows = data.len() / window_samples;
    
    let mut energies = Vec::new();
    for i in 0..n_windows {
        let start = i * window_samples;
        let end = (start + window_samples).min(data.len());
        let window = &data[start..end];
        
        let energy: f32 = window.iter().map(|x| x * x).sum::<f32>() / window.len() as f32;
        energies.push(energy.sqrt());
    }
    
    energies
}

fn detect_transients(data: &[f32], sample_rate: u32) -> Vec<(f32, f32)> {
    let energies = analyze_energy(data, sample_rate, 0.01);
    
    let mean: f32 = energies.iter().sum::<f32>() / energies.len() as f32;
    let variance: f32 = energies.iter().map(|e| (e - mean).powi(2)).sum::<f32>() / energies.len() as f32;
    let std = variance.sqrt();
    let threshold = mean + 2.5 * std;
    
    let mut transients = Vec::new();
    for (i, &energy) in energies.iter().enumerate() {
        if energy > threshold {
            let time = i as f32 * 0.01;
            transients.push((time, energy));
        }
    }
    
    transients
}

fn detect_continuous_noise(data: &[f32], sample_rate: u32) -> (f32, f32) {
    let energies = analyze_energy(data, sample_rate, 0.5);
    
    let mean: f32 = energies.iter().sum::<f32>() / energies.len() as f32;
    let variance: f32 = energies.iter().map(|e| (e - mean).powi(2)).sum::<f32>() / energies.len() as f32;
    let std = variance.sqrt();
    let consistency = 1.0 - (std / mean);
    
    (mean, consistency)
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let filename = "/tmp/mic_test.wav";
    println!("Analyzing: {}", filename);
    
    let (data, sample_rate) = load_wav(filename)?;
    let duration = data.len() as f32 / sample_rate as f32;
    
    println!("Duration: {:.2}s", duration);
    println!("Sample rate: {}Hz", sample_rate);
    println!("Samples: {}", data.len());
    println!();
    
    // Overall statistics
    let rms: f32 = (data.iter().map(|x| x * x).sum::<f32>() / data.len() as f32).sqrt();
    let peak: f32 = data.iter().map(|x| x.abs()).fold(0.0, f32::max);
    println!("RMS level: {:.1}", rms);
    println!("Peak level: {:.1}", peak);
    println!();
    
    // Detect transients (snaps)
    println!("🫰 DETECTING SNAPS (transients)...");
    let transients = detect_transients(&data, sample_rate);
    println!("Found {} potential snaps:", transients.len());
    for (time, energy) in transients.iter().take(10) {
        println!("  {:.2}s - energy: {:.1}", time, energy);
    }
    if transients.len() > 10 {
        println!("  ... and {} more", transients.len() - 10);
    }
    println!();
    
    // Detect continuous noise (fan)
    println!("🌀 DETECTING FAN (continuous noise)...");
    let (mean_energy, consistency) = detect_continuous_noise(&data, sample_rate);
    println!("Background energy: {:.1}", mean_energy);
    println!("Consistency: {:.2}%", consistency * 100.0);
    if consistency > 0.7 {
        println!("  → Likely continuous fan noise present");
    }
    println!();
    
    // Analyze speech patterns
    println!("🎙️ DETECTING SPEECH/PODCAST...");
    let energies = analyze_energy(&data, sample_rate, 0.1);
    let mean: f32 = energies.iter().sum::<f32>() / energies.len() as f32;
    let variance: f32 = energies.iter().map(|e| (e - mean).powi(2)).sum::<f32>() / energies.len() as f32;
    let std = variance.sqrt();
    let speech_variation = std / mean;
    println!("Energy variation: {:.2}", speech_variation);
    if speech_variation > 0.3 && speech_variation < 1.5 {
        println!("  → Speech/podcast patterns detected");
    }
    println!();
    
    // Detect activity periods
    println!("🍳 DETECTING KITCHEN ACTIVITY...");
    let threshold = mean + 0.5 * std;
    let mut active_periods = Vec::new();
    let mut in_period = false;
    let mut start_time = 0.0;
    
    for (i, &energy) in energies.iter().enumerate() {
        let time = i as f32 * 0.1;
        if energy > threshold && !in_period {
            start_time = time;
            in_period = true;
        } else if energy <= threshold && in_period {
            active_periods.push((start_time, time));
            in_period = false;
        }
    }
    
    println!("Found {} activity periods:", active_periods.len());
    for (start, end) in active_periods.iter().take(5) {
        println!("  {:.1}s - {:.1}s ({:.1}s)", start, end, end - start);
    }
    if active_periods.len() > 5 {
        println!("  ... and {} more", active_periods.len() - 5);
    }
    println!();
    
    // Summary
    println!("{}", "=".repeat(60));
    println!("CLASSIFICATION SUMMARY:");
    println!("{}", "=".repeat(60));
    println!("🫰 Snaps: {} detected", transients.len());
    println!("🌀 Fan: {}", if consistency > 0.7 { "Present" } else { "Not detected" });
    println!("🎙️ Podcast: {}", if speech_variation > 0.3 && speech_variation < 1.5 { "Detected" } else { "Not detected" });
    println!("🍳 Kitchen: {} activity periods", active_periods.len());
    
    Ok(())
}
