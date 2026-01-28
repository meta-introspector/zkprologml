// AUTO-GENERATED: Rust version of Prolog predicates
// Compiled for speed

use std::fs;
use std::process::Command;
use std::path::Path;


fn factorial(n: i32) -> i32 {
    if n <= 0 {
        1
    } else {
        n * factorial(n - 1)
    }
}


use std::fs;
use std::path::Path;

fn search_files(pattern: &str) -> Vec<String> {
    let mut results = Vec::new();
    
    if let Ok(entries) = fs::read_dir(".") {
        for entry in entries.flatten() {
            if let Some(name) = entry.file_name().to_str() {
                if name.contains(pattern) {
                    results.push(name.to_string());
                }
            }
        }
    }
    
    results
}


use std::process::Command;

fn test_compiler(compiler: &str, source: &str, output: &str) -> Result<(), String> {
    let status = Command::new(compiler)
        .arg(source)
        .arg("-o")
        .arg(output)
        .status()
        .map_err(|e| e.to_string())?;
    
    if status.success() {
        Ok(())
    } else {
        Err(format!("Compilation failed with {}", compiler))
    }
}


fn main() {
    println!("🦀 Rust version running!");
    
    // Test factorial
    let result = factorial(10);
    println!("factorial(10) = {}", result);
    
    // Test search
    let files = search_files("test");
    println!("Found {} files", files.len());
    
    // Test compiler
    match test_compiler("gcc", "test.c", "test") {
        Ok(_) => println!("✅ Compilation successful"),
        Err(e) => println!("❌ {}", e),
    }
}
