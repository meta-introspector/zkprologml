// build.rs - Nix-aware Rust build script

use std::env;
use std::path::PathBuf;

fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    
    // Check if running in Nix build
    if let Ok(nix_build) = env::var("IN_NIX_SHELL") {
        println!("cargo:warning=Building in Nix shell: {}", nix_build);
    }
    
    // Get data directory
    let data_dir = env::var("PWD").unwrap_or_else(|_| ".".to_string());
    println!("cargo:warning=Data directory: {}", data_dir);
    
    // Check for master.parquet
    let master_parquet = PathBuf::from(&data_dir).join("master.parquet");
    if master_parquet.exists() {
        println!("cargo:warning=✅ Found master.parquet");
        println!("cargo:rustc-env=MASTER_PARQUET={}", master_parquet.display());
    } else {
        println!("cargo:warning=❌ master.parquet not found");
    }
    
    // Check for global_objects.pl
    let global_objects = PathBuf::from(&data_dir).join("global_objects.pl");
    if global_objects.exists() {
        println!("cargo:warning=✅ Found global_objects.pl");
        println!("cargo:rustc-env=GLOBAL_OBJECTS_PL={}", global_objects.display());
    } else {
        println!("cargo:warning=❌ global_objects.pl not found");
    }
    
    // Set Monster Group modulus
    println!("cargo:rustc-env=MONSTER_MOD=71");
    
    // Set shard count
    println!("cargo:rustc-env=SHARD_COUNT=71");
}
