// usage_pattern_analyzer.rs - Analyze usage patterns and forecast reuse

use std::collections::HashMap;
use std::fs::File;
use std::io::Write;

#[derive(Debug, Clone)]
struct AccessEvent {
    timestamp: u64,
    path: String,
    operation: String,
}

#[derive(Debug)]
struct UsagePattern {
    path: String,
    access_sequence: Vec<u64>,
    frequency: usize,
    avg_interval: f64,
    labels: Vec<String>,
    forecast_score: f64,
}

struct PatternAnalyzer {
    events: Vec<AccessEvent>,
    patterns: HashMap<String, UsagePattern>,
}

impl PatternAnalyzer {
    fn new() -> Self {
        PatternAnalyzer {
            events: Vec::new(),
            patterns: HashMap::new(),
        }
    }
    
    fn record_access(&mut self, timestamp: u64, path: &str, operation: &str) {
        self.events.push(AccessEvent {
            timestamp,
            path: path.to_string(),
            operation: operation.to_string(),
        });
    }
    
    fn analyze_patterns(&mut self) {
        println!("🔍 Analyzing usage patterns...\n");
        
        // Group by path
        let mut path_events: HashMap<String, Vec<u64>> = HashMap::new();
        
        for event in &self.events {
            path_events.entry(event.path.clone())
                .or_insert_with(Vec::new)
                .push(event.timestamp);
        }
        
        // Analyze each path
        for (path, mut timestamps) in path_events {
            timestamps.sort();
            
            let frequency = timestamps.len();
            
            // Calculate average interval
            let intervals: Vec<u64> = timestamps.windows(2)
                .map(|w| w[1] - w[0])
                .collect();
            
            let avg_interval = if intervals.is_empty() {
                0.0
            } else {
                intervals.iter().sum::<u64>() as f64 / intervals.len() as f64
            };
            
            // Label based on pattern
            let labels = self.label_pattern(frequency, avg_interval);
            
            // Forecast reuse probability
            let forecast_score = self.forecast_reuse(frequency, avg_interval);
            
            self.patterns.insert(path.clone(), UsagePattern {
                path: path.clone(),
                access_sequence: timestamps,
                frequency,
                avg_interval,
                labels,
                forecast_score,
            });
            
            println!("  {} - {} accesses, interval: {:.2}s, forecast: {:.2}",
                     path, frequency, avg_interval, forecast_score);
        }
    }
    
    fn label_pattern(&self, frequency: usize, avg_interval: f64) -> Vec<String> {
        let mut labels = Vec::new();
        
        // Frequency labels
        if frequency > 10 {
            labels.push("hot".to_string());
        } else if frequency > 5 {
            labels.push("warm".to_string());
        } else {
            labels.push("cold".to_string());
        }
        
        // Interval labels
        if avg_interval < 1.0 {
            labels.push("burst".to_string());
        } else if avg_interval < 10.0 {
            labels.push("frequent".to_string());
        } else if avg_interval < 60.0 {
            labels.push("periodic".to_string());
        } else {
            labels.push("sporadic".to_string());
        }
        
        // Pattern labels
        if frequency > 5 && avg_interval < 5.0 {
            labels.push("cache_candidate".to_string());
        }
        
        if frequency > 3 && avg_interval > 30.0 {
            labels.push("prefetch_candidate".to_string());
        }
        
        labels
    }
    
    fn forecast_reuse(&self, frequency: usize, avg_interval: f64) -> f64 {
        // Simple forecast: frequency / (1 + avg_interval)
        // Higher frequency + lower interval = higher reuse probability
        let base_score = frequency as f64 / (1.0 + avg_interval);
        
        // Normalize to 0-1
        base_score.min(1.0)
    }
    
    fn save_patterns(&self) {
        println!("\n💾 Saving patterns...");
        
        // Save to CSV
        let mut file = File::create("generated/usage_patterns.csv").unwrap();
        writeln!(file, "path,frequency,avg_interval,labels,forecast_score").unwrap();
        
        for pattern in self.patterns.values() {
            writeln!(file, "{},{},{:.2},{},{:.4}",
                pattern.path,
                pattern.frequency,
                pattern.avg_interval,
                pattern.labels.join(";"),
                pattern.forecast_score
            ).unwrap();
        }
        
        println!("  ✅ Saved to generated/usage_patterns.csv");
    }
    
    fn recommend_actions(&self) {
        println!("\n💡 RECOMMENDATIONS");
        println!("═══════════════════════════════════════════════════════════");
        
        // Sort by forecast score
        let mut sorted: Vec<_> = self.patterns.values().collect();
        sorted.sort_by(|a, b| b.forecast_score.partial_cmp(&a.forecast_score).unwrap());
        
        for pattern in sorted.iter().take(5) {
            println!("\n  {} (forecast: {:.2})", pattern.path, pattern.forecast_score);
            
            if pattern.labels.contains(&"cache_candidate".to_string()) {
                println!("    → Keep in cache (hot + frequent)");
            }
            
            if pattern.labels.contains(&"prefetch_candidate".to_string()) {
                println!("    → Prefetch before next access");
            }
            
            if pattern.labels.contains(&"hot".to_string()) {
                println!("    → Pin in memory");
            }
            
            if pattern.labels.contains(&"cold".to_string()) {
                println!("    → Consider eviction");
            }
        }
    }
}

fn main() {
    println!("\n📊 USAGE PATTERN ANALYZER");
    println!("═══════════════════════════════════════════════════════════\n");
    
    let mut analyzer = PatternAnalyzer::new();
    
    // Simulate access events (in production, load from logs)
    println!("📝 Recording access events...\n");
    
    let base_time = 1000000;
    
    // Hot file: merged_constants.pl
    for i in 0..15 {
        analyzer.record_access(base_time + i * 2, "generated/merged_constants.pl", "read");
    }
    
    // Warm file: llm.txt
    for i in 0..7 {
        analyzer.record_access(base_time + i * 5, "generated/llm.txt", "read");
    }
    
    // Cold file: perf_samples.csv
    for i in 0..3 {
        analyzer.record_access(base_time + i * 30, "generated/perf_samples.csv", "read");
    }
    
    // Burst file: godel_lattice.csv
    for i in 0..10 {
        analyzer.record_access(base_time + i, "generated/godel_lattice.csv", "read");
    }
    
    println!("  Recorded {} events", analyzer.events.len());
    
    // Analyze patterns
    analyzer.analyze_patterns();
    
    // Save patterns
    analyzer.save_patterns();
    
    // Recommendations
    analyzer.recommend_actions();
    
    // Statistics
    println!("\n📊 STATISTICS");
    println!("═══════════════════════════════════════════════════════════");
    println!("  Total events: {}", analyzer.events.len());
    println!("  Unique paths: {}", analyzer.patterns.len());
    
    let hot_count = analyzer.patterns.values()
        .filter(|p| p.labels.contains(&"hot".to_string()))
        .count();
    println!("  Hot files: {}", hot_count);
    
    let cache_candidates = analyzer.patterns.values()
        .filter(|p| p.labels.contains(&"cache_candidate".to_string()))
        .count();
    println!("  Cache candidates: {}", cache_candidates);
    
    println!("\n✅ COMPLETE");
    println!("\nUsage patterns analyzed and labeled for forecasting!");
}
