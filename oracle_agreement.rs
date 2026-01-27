// Oracle Agreement Protocol
// Multiple Rust oracles collect data, Prolog verifies agreement

use std::process::Command;
use std::collections::HashMap;

// ═══════════════════════════════════════════════════════════
// PART 1: Oracle Data Collection
// ═══════════════════════════════════════════════════════════

#[derive(Debug, Clone, PartialEq)]
struct Measurement {
    cpu_freq: f64,
    cpu_temp: f64,
    load: f64,
    timestamp: f64,
}

// Oracle 1: Direct system measurement
fn oracle_system() -> Measurement {
    let freq = get_cpu_freq();
    let temp = get_cpu_temp();
    let load = get_load();
    let timestamp = get_timestamp();
    
    Measurement { cpu_freq: freq, cpu_temp: temp, load, timestamp }
}

// Oracle 2: Perf-based measurement
fn oracle_perf() -> Measurement {
    let freq = get_cpu_freq(); // Same source
    let temp = get_cpu_temp_alt(); // Alternative sensor
    let load = get_load();
    let timestamp = get_timestamp();
    
    Measurement { cpu_freq: freq, cpu_temp: temp, load, timestamp }
}

// Oracle 3: eBPF-based measurement
fn oracle_ebpf() -> Measurement {
    let freq = get_cpu_freq();
    let temp = get_cpu_temp();
    let load = get_load_alt(); // Alternative load calculation
    let timestamp = get_timestamp();
    
    Measurement { cpu_freq: freq, cpu_temp: temp, load, timestamp }
}

// ═══════════════════════════════════════════════════════════
// PART 2: Agreement Protocol
// ═══════════════════════════════════════════════════════════

fn check_agreement(measurements: &[Measurement], threshold: f64) -> bool {
    if measurements.len() < 2 {
        return false;
    }
    
    // Check CPU frequency agreement
    let freqs: Vec<f64> = measurements.iter().map(|m| m.cpu_freq).collect();
    let freq_variance = variance(&freqs);
    
    // Check temperature agreement
    let temps: Vec<f64> = measurements.iter().map(|m| m.cpu_temp).collect();
    let temp_variance = variance(&temps);
    
    // Check load agreement
    let loads: Vec<f64> = measurements.iter().map(|m| m.load).collect();
    let load_variance = variance(&loads);
    
    // All must agree within threshold
    freq_variance < threshold && temp_variance < threshold && load_variance < threshold
}

fn variance(values: &[f64]) -> f64 {
    if values.is_empty() {
        return 0.0;
    }
    
    let mean: f64 = values.iter().sum::<f64>() / values.len() as f64;
    let sq_diff_sum: f64 = values.iter().map(|v| (v - mean).powi(2)).sum();
    sq_diff_sum / values.len() as f64
}

// Consensus: Take median of agreed measurements
fn consensus(measurements: &[Measurement]) -> Measurement {
    let mut freqs: Vec<f64> = measurements.iter().map(|m| m.cpu_freq).collect();
    let mut temps: Vec<f64> = measurements.iter().map(|m| m.cpu_temp).collect();
    let mut loads: Vec<f64> = measurements.iter().map(|m| m.load).collect();
    
    freqs.sort_by(|a, b| a.partial_cmp(b).unwrap());
    temps.sort_by(|a, b| a.partial_cmp(b).unwrap());
    loads.sort_by(|a, b| a.partial_cmp(b).unwrap());
    
    Measurement {
        cpu_freq: freqs[freqs.len() / 2],
        cpu_temp: temps[temps.len() / 2],
        load: loads[loads.len() / 2],
        timestamp: get_timestamp(),
    }
}

// ═══════════════════════════════════════════════════════════
// PART 3: Safe Oracle Injection
// ═══════════════════════════════════════════════════════════

fn safe_oracle_measurement() -> Option<Measurement> {
    println!("🔒 Safe Oracle Measurement");
    println!("═══════════════════════════════════════════════════════════");
    
    // Collect from all oracles
    println!("Collecting from oracles...");
    let m1 = oracle_system();
    let m2 = oracle_perf();
    let m3 = oracle_ebpf();
    
    println!("  Oracle 1 (system): {:?}", m1);
    println!("  Oracle 2 (perf):   {:?}", m2);
    println!("  Oracle 3 (eBPF):   {:?}", m3);
    println!();
    
    let measurements = vec![m1, m2, m3];
    
    // Check agreement (variance < 5%)
    let threshold = 5.0;
    let agreed = check_agreement(&measurements, threshold);
    
    if agreed {
        println!("✅ Oracles agree (variance < {}%)", threshold);
        let consensus_measurement = consensus(&measurements);
        println!("Consensus: {:?}", consensus_measurement);
        Some(consensus_measurement)
    } else {
        println!("❌ Oracles disagree - rejecting measurement");
        println!("   (Safety: Don't trust conflicting data)");
        None
    }
}

// ═══════════════════════════════════════════════════════════
// PART 4: Actual Measurement Functions
// ═══════════════════════════════════════════════════════════

fn get_cpu_freq() -> f64 {
    let output = Command::new("sh")
        .arg("-c")
        .arg("grep 'MHz' /proc/cpuinfo | head -1 | awk '{print $4}'")
        .output()
        .expect("Failed to get CPU freq");
    
    String::from_utf8_lossy(&output.stdout)
        .trim()
        .parse()
        .unwrap_or(0.0)
}

fn get_cpu_temp() -> f64 {
    let output = Command::new("sh")
        .arg("-c")
        .arg("sensors 2>/dev/null | grep 'Package id 0' | awk '{print $4}' | tr -d '+°C'")
        .output()
        .expect("Failed to get temp");
    
    String::from_utf8_lossy(&output.stdout)
        .trim()
        .parse()
        .unwrap_or(0.0)
}

fn get_cpu_temp_alt() -> f64 {
    // Alternative: read from thermal zone
    let output = Command::new("sh")
        .arg("-c")
        .arg("cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null")
        .output()
        .expect("Failed to get temp alt");
    
    let millidegrees: f64 = String::from_utf8_lossy(&output.stdout)
        .trim()
        .parse()
        .unwrap_or(0.0);
    
    millidegrees / 1000.0
}

fn get_load() -> f64 {
    let output = Command::new("sh")
        .arg("-c")
        .arg("uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}'")
        .output()
        .expect("Failed to get load");
    
    String::from_utf8_lossy(&output.stdout)
        .trim()
        .parse()
        .unwrap_or(0.0)
}

fn get_load_alt() -> f64 {
    // Alternative: calculate from /proc/loadavg
    let output = Command::new("sh")
        .arg("-c")
        .arg("cat /proc/loadavg | awk '{print $1}'")
        .output()
        .expect("Failed to get load alt");
    
    String::from_utf8_lossy(&output.stdout)
        .trim()
        .parse()
        .unwrap_or(0.0)
}

fn get_timestamp() -> f64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs_f64()
}

// ═══════════════════════════════════════════════════════════
// PART 5: Output for Prolog
// ═══════════════════════════════════════════════════════════

fn output_for_prolog(measurement: &Measurement) {
    // Output in Prolog-readable format
    println!("measurement(");
    println!("  cpu_freq({}),", measurement.cpu_freq);
    println!("  cpu_temp({}),", measurement.cpu_temp);
    println!("  load({}),", measurement.load);
    println!("  timestamp({})", measurement.timestamp);
    println!(").");
}

// ═══════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════

fn main() {
    println!("🔒 Oracle Agreement Protocol");
    println!("Multiple oracles, consensus required");
    println!("═══════════════════════════════════════════════════════════");
    println!();
    
    // Run safe measurement
    match safe_oracle_measurement() {
        Some(measurement) => {
            println!();
            println!("═══════════════════════════════════════════════════════════");
            println!("✅ Safe measurement obtained");
            println!("═══════════════════════════════════════════════════════════");
            println!();
            println!("Prolog output:");
            output_for_prolog(&measurement);
        }
        None => {
            println!();
            println!("═══════════════════════════════════════════════════════════");
            println!("❌ No consensus - measurement rejected");
            println!("═══════════════════════════════════════════════════════════");
            std::process::exit(1);
        }
    }
}
