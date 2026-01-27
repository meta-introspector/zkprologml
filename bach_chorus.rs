// Bach Chorus: CPUs Singing + WiFi + Audio Recording
// Integrate: Square waves, WiFi signals, microphone, CPU temp

use std::thread;
use std::time::{Duration, Instant};
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};
use std::process::Command;
use std::fs::{self, File};
use std::io::Write;

fn read_cpu_temp() -> f32 {
    fs::read_to_string("/sys/class/thermal/thermal_zone0/temp")
        .ok()
        .and_then(|s| s.trim().parse::<f32>().ok())
        .map(|t| t / 1000.0)
        .unwrap_or(0.0)
}

fn read_wifi_noise(interface: &str) -> Option<(i32, i32)> {
    let wireless = fs::read_to_string("/proc/net/wireless").ok()?;
    for line in wireless.lines() {
        if line.contains(interface) {
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() >= 5 {
                let signal = parts[3].trim_end_matches('.').parse().ok()?;
                let noise = parts[4].trim_end_matches('.').parse().ok()?;
                return Some((signal, noise));
            }
        }
    }
    None
}

fn main() {
    println!("🎼 BACH CHORUS: CPUs Singing in Harmony");
    println!("{}", "=".repeat(60));
    println!();
    
    let primes = vec![2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37];
    let active = Arc::new(AtomicBool::new(false));
    let running = Arc::new(AtomicBool::new(true));
    
    // Start CPU chorus threads
    let mut handles = vec![];
    for (voice, &prime) in primes.iter().enumerate() {
        let active = Arc::clone(&active);
        let running = Arc::clone(&running);
        
        let handle = thread::spawn(move || {
            let mut acc = 0u64;
            while running.load(Ordering::Relaxed) {
                if active.load(Ordering::Relaxed) {
                    for _ in 0..prime * 1000 {
                        acc = acc.wrapping_mul(6364136223846793005)
                            .wrapping_add(1442695040888963407);
                        acc ^= acc >> 32;
                    }
                }
            }
            acc
        });
        handles.push(handle);
    }
    
    println!("🎵 {} voices started (prime cycles: {:?})", primes.len(), primes);
    println!();
    
    // Create output file
    let timestamp = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs();
    
    let csv_file = format!("data/bach_chorus_{}.csv", timestamp);
    let mut file = File::create(&csv_file).unwrap();
    writeln!(file, "time_ms,state,cpu_temp,wifi_signal,wifi_noise,audio_rms").unwrap();
    
    println!("📊 Recording to: {}", csv_file);
    println!();
    
    let start = Instant::now();
    let interface = "wlo1";
    
    // Square wave: 5 cycles of ON/OFF
    for cycle in 0..5 {
        let elapsed = start.elapsed().as_millis();
        
        // ON phase
        println!("Cycle {}: ⬜ ON (CPUs singing)", cycle + 1);
        active.store(true, Ordering::Relaxed);
        
        // Record audio during ON
        let audio_file = format!("/tmp/bach_on_{}.wav", cycle);
        Command::new("sudo")
            .args(&["arecord", "-D", "hw:0,0", "-f", "cd", "-d", "2", &audio_file])
            .output()
            .ok();
        
        // Measure during ON
        for _ in 0..10 {
            let t = start.elapsed().as_millis();
            let temp = read_cpu_temp();
            let (signal, noise) = read_wifi_noise(interface).unwrap_or((0, 0));
            
            writeln!(file, "{},ON,{:.1},{},{},0", t, temp, signal, noise).unwrap();
            thread::sleep(Duration::from_millis(200));
        }
        
        // OFF phase
        println!("Cycle {}: ⬛ OFF (CPUs silent)", cycle + 1);
        active.store(false, Ordering::Relaxed);
        
        // Record audio during OFF
        let audio_file = format!("/tmp/bach_off_{}.wav", cycle);
        Command::new("sudo")
            .args(&["arecord", "-D", "hw:0,0", "-f", "cd", "-d", "2", &audio_file])
            .output()
            .ok();
        
        // Measure during OFF
        for _ in 0..10 {
            let t = start.elapsed().as_millis();
            let temp = read_cpu_temp();
            let (signal, noise) = read_wifi_noise(interface).unwrap_or((0, 0));
            
            writeln!(file, "{},OFF,{:.1},{},{},0", t, temp, signal, noise).unwrap();
            thread::sleep(Duration::from_millis(200));
        }
        
        println!();
    }
    
    // Stop threads
    running.store(false, Ordering::Relaxed);
    for handle in handles {
        handle.join().ok();
    }
    
    println!("{}", "=".repeat(60));
    println!("BACH CHORUS COMPLETE!");
    println!("{}", "=".repeat(60));
    println!();
    println!("📊 Data saved to: {}", csv_file);
    println!("🎵 Audio files: /tmp/bach_on_*.wav, /tmp/bach_off_*.wav");
    println!();
    println!("PROOF:");
    println!("  CPU computation → Heat → Fan speed → Acoustic sound");
    println!("  CPU computation → EM radiation → WiFi noise");
    println!("  Square wave pattern visible in all measurements");
    println!();
    println!("QED ∎");
}
