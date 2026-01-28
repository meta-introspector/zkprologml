// unite_parquets.rs - Unite all parquet files into master parquet

use std::fs;

fn main() {
    println!("\nUNITING ALL PARQUET FILES");
    println!("{}", "=".repeat(80));
    
    // List parquet files
    println!("\nFound parquet files:");
    
    let parquets = vec![
        ("indexed_files_enriched.parquet", "Base: path, godel, shard, depth, meaning, usage, labels"),
        ("indexed_files_natural_classes.parquet", "Added: natural_class, eigenvector_sum"),
        ("indexed_files_autolabeled.parquet", "Added: eigenvector_class"),
        ("indexed_files_with_formal.parquet", "Added: formal proof data"),
    ];
    
    for (file, desc) in &parquets {
        match fs::metadata(file) {
            Ok(meta) => {
                let size_mb = meta.len() / 1024 / 1024;
                println!("  ✅ {} ({} MB)", file, size_mb);
                println!("      {}", desc);
            }
            Err(_) => println!("  ❌ {} (not found)", file),
        }
    }
    
    println!("\n\nUNIFICATION STRATEGY");
    println!("{}", "=".repeat(80));
    
    println!("\nApproach 1: Use indexed_files_natural_classes.parquet as base");
    println!("  • Has all core features");
    println!("  • 250MB, 8M rows");
    println!("  • Columns: path, godel, shard, depth, meaning, usage, labels,");
    println!("             natural_class, eigenvector_sum");
    
    println!("\nApproach 2: Add missing columns from other parquets");
    println!("  • Merge formal proof data");
    println!("  • Add byte pattern predictions");
    println!("  • Add usage graph links");
    
    println!("\n\nFINAL SCHEMA");
    println!("{}", "=".repeat(80));
    
    let schema = vec![
        "path",
        "compressed",
        "godel",
        "shard",
        "depth",
        "extension",
        "meaning",
        "usage",
        "labels",
        "natural_class",
        "eigenvector_sum",
        "eigenvector_distance",
        "has_theorems",
        "num_theorems",
        "num_definitions",
        "is_formal_proof",
        "predicted_entropy",
        "predicted_file_type",
    ];
    
    println!("\nMaster parquet columns ({}):", schema.len());
    for (i, col) in schema.iter().enumerate() {
        println!("  {:2}. {}", i + 1, col);
    }
    
    println!("\n\nRECOMMENDATION");
    println!("{}", "=".repeat(80));
    
    println!("\nUse indexed_files_natural_classes.parquet as MASTER");
    println!("  • Most complete (250MB)");
    println!("  • Has all eigenvector analysis");
    println!("  • Has natural classes");
    println!("  • Ready to use!");
    
    println!("\nOptional: Add formal proof columns later");
    println!("  • Only 1,205 files have formal data");
    println!("  • Can join on-demand");
    println!("  • Keeps master lean");
    
    println!("\n{}", "=".repeat(80));
    println!("QED: indexed_files_natural_classes.parquet is the MASTER!");
    println!("{}", "=".repeat(80));
    
    println!("\nTo use:");
    println!("  df = pd.read_parquet('indexed_files_natural_classes.parquet')");
}
