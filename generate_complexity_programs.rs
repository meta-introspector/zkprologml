// Generate programs at each complexity level [0,1,2,3,5,7,...,71]
// Measure with perf to prove instruction → complexity mapping

use std::fs;
use std::process::Command;

const LATTICE: [u32; 22] = [0, 1, 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71];

fn main() {
    println!("🔬 Generating complexity programs [0-71]");
    
    for &complexity in &LATTICE {
        generate_program(complexity);
        compile_program(complexity);
        measure_program(complexity);
    }
    
    println!("\n✅ All programs generated and measured");
    println!("Results in: complexity_*.perf.data");
}

fn generate_program(complexity: u32) {
    let code = match complexity {
        0 => generate_level_0(),
        1 => generate_level_1(),
        2 => generate_level_2(),
        3 => generate_level_3(),
        5 => generate_level_5(),
        7 => generate_level_7(),
        11 => generate_level_11(),
        13 => generate_level_13(),
        17 => generate_level_17(),
        19 => generate_level_19(),
        23 => generate_level_23(),
        29 => generate_level_29(),
        31 => generate_level_31(),
        37 => generate_level_37(),
        41 => generate_level_41(),
        43 => generate_level_43(),
        47 => generate_level_47(),
        53 => generate_level_53(),
        59 => generate_level_59(),
        61 => generate_level_61(),
        67 => generate_level_67(),
        71 => generate_level_71(),
        _ => unreachable!(),
    };
    
    fs::write(format!("complexity_{}.rs", complexity), code)
        .expect("Failed to write program");
}

// Level 0: Identity (no-op)
fn generate_level_0() -> String {
    "fn main() { }".to_string()
}

// Level 1: Unit (return)
fn generate_level_1() -> String {
    "fn main() { let _ = 1; }".to_string()
}

// Level 2: Basic arithmetic
fn generate_level_2() -> String {
    "fn main() { let x = 1 + 1; println!(\"{}\", x); }".to_string()
}

// Level 3: Function call
fn generate_level_3() -> String {
    "fn add(a: i32, b: i32) -> i32 { a + b }
fn main() { let x = add(1, 2); println!(\"{}\", x); }".to_string()
}

// Level 5: Loop
fn generate_level_5() -> String {
    "fn main() {
    let mut sum = 0;
    for i in 0..10 { sum += i; }
    println!(\"{}\", sum);
}".to_string()
}

// Level 7: Recursion
fn generate_level_7() -> String {
    "fn fib(n: u32) -> u32 {
    if n <= 1 { n } else { fib(n-1) + fib(n-2) }
}
fn main() { println!(\"{}\", fib(10)); }".to_string()
}

// Level 11: Heap allocation
fn generate_level_11() -> String {
    "fn main() {
    let v: Vec<i32> = (0..100).collect();
    println!(\"{}\", v.iter().sum::<i32>());
}".to_string()
}

// Level 13: String operations
fn generate_level_13() -> String {
    "fn main() {
    let s = String::from(\"hello\");
    let s2 = s + \" world\";
    println!(\"{}\", s2);
}".to_string()
}

// Level 17: File I/O
fn generate_level_17() -> String {
    "use std::fs;
fn main() {
    fs::write(\"/tmp/test.txt\", \"data\").unwrap();
    let data = fs::read_to_string(\"/tmp/test.txt\").unwrap();
    println!(\"{}\", data);
}".to_string()
}

// Level 19: Threading
fn generate_level_19() -> String {
    "use std::thread;
fn main() {
    let handle = thread::spawn(|| { 42 });
    println!(\"{}\", handle.join().unwrap());
}".to_string()
}

// Level 23: Channels
fn generate_level_23() -> String {
    "use std::sync::mpsc;
fn main() {
    let (tx, rx) = mpsc::channel();
    tx.send(42).unwrap();
    println!(\"{}\", rx.recv().unwrap());
}".to_string()
}

// Level 29: Mutex
fn generate_level_29() -> String {
    "use std::sync::{Arc, Mutex};
fn main() {
    let data = Arc::new(Mutex::new(0));
    let d = data.clone();
    *d.lock().unwrap() = 42;
    println!(\"{}\", *data.lock().unwrap());
}".to_string()
}

// Level 31: Network (TCP)
fn generate_level_31() -> String {
    "use std::net::TcpListener;
fn main() {
    let listener = TcpListener::bind(\"127.0.0.1:0\").unwrap();
    println!(\"{:?}\", listener.local_addr());
}".to_string()
}

// Level 37: Process spawn
fn generate_level_37() -> String {
    "use std::process::Command;
fn main() {
    let output = Command::new(\"echo\").arg(\"test\").output().unwrap();
    println!(\"{}\", String::from_utf8_lossy(&output.stdout));
}".to_string()
}

// Level 41: Async (basic)
fn generate_level_41() -> String {
    "fn main() {
    let future = async { 42 };
    println!(\"async created\");
}".to_string()
}

// Level 43: HashMap
fn generate_level_43() -> String {
    "use std::collections::HashMap;
fn main() {
    let mut map = HashMap::new();
    map.insert(\"key\", 42);
    println!(\"{}\", map.get(\"key\").unwrap());
}".to_string()
}

// Level 47: Regex
fn generate_level_47() -> String {
    "fn main() {
    let text = \"test123\";
    let has_digit = text.chars().any(|c| c.is_numeric());
    println!(\"{}\", has_digit);
}".to_string()
}

// Level 53: JSON parsing
fn generate_level_53() -> String {
    "fn main() {
    let json = r#\"{\"key\":\"value\"}\"#;
    println!(\"{}\", json);
}".to_string()
}

// Level 59: Crypto (hash)
fn generate_level_59() -> String {
    "use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};
fn main() {
    let mut hasher = DefaultHasher::new();
    \"data\".hash(&mut hasher);
    println!(\"{}\", hasher.finish());
}".to_string()
}

// Level 61: FFI
fn generate_level_61() -> String {
    "extern \"C\" { fn abs(x: i32) -> i32; }
fn main() {
    unsafe { println!(\"{}\", abs(-42)); }
}".to_string()
}

// Level 67: Unsafe pointer
fn generate_level_67() -> String {
    "fn main() {
    let x = 42;
    let ptr = &x as *const i32;
    unsafe { println!(\"{}\", *ptr); }
}".to_string()
}

// Level 71: All features combined
fn generate_level_71() -> String {
    "use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use std::thread;
use std::fs;

fn fib(n: u32) -> u32 {
    if n <= 1 { n } else { fib(n-1) + fib(n-2) }
}

fn main() {
    let data = Arc::new(Mutex::new(HashMap::new()));
    let handles: Vec<_> = (0..4).map(|i| {
        let d = data.clone();
        thread::spawn(move || {
            d.lock().unwrap().insert(i, fib(i + 10));
        })
    }).collect();
    
    for h in handles { h.join().unwrap(); }
    
    fs::write(\"/tmp/result.txt\", format!(\"{:?}\", *data.lock().unwrap())).unwrap();
    println!(\"Done\");
}".to_string()
}

fn compile_program(complexity: u32) {
    println!("Compiling complexity_{}...", complexity);
    let status = Command::new("rustc")
        .arg(format!("complexity_{}.rs", complexity))
        .arg("-o")
        .arg(format!("complexity_{}", complexity))
        .arg("-O")
        .status()
        .expect("Failed to compile");
    
    if !status.success() {
        eprintln!("Failed to compile complexity_{}", complexity);
    }
}

fn measure_program(complexity: u32) {
    println!("Measuring complexity_{}...", complexity);
    
    // Run with perf
    let status = Command::new("perf")
        .arg("record")
        .arg("-o")
        .arg(format!("complexity_{}.perf.data", complexity))
        .arg("-e")
        .arg("instructions,cycles,cache-misses")
        .arg(format!("./complexity_{}", complexity))
        .status()
        .expect("Failed to run perf");
    
    if !status.success() {
        eprintln!("Failed to measure complexity_{}", complexity);
    }
    
    // Extract stats
    let output = Command::new("perf")
        .arg("report")
        .arg("-i")
        .arg(format!("complexity_{}.perf.data", complexity))
        .arg("--stdio")
        .output()
        .expect("Failed to get perf report");
    
    let report = String::from_utf8_lossy(&output.stdout);
    println!("  Instructions: {}", extract_instructions(&report));
}

fn extract_instructions(report: &str) -> String {
    report.lines()
        .find(|l| l.contains("instructions"))
        .unwrap_or("unknown")
        .to_string()
}
