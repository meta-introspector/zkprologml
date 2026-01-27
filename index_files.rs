use std::fs;
use std::collections::HashMap;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("📋 Indexing and Documenting All Files\n");
    
    // Find all .rs files
    let mut files: Vec<_> = fs::read_dir(".")?
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().map(|ext| ext == "rs").unwrap_or(false))
        .map(|e| e.path())
        .collect();
    
    files.sort();
    
    println!("Found {} Rust files\n", files.len());
    
    let mut index = String::from("# File Index and Documentation\n\n");
    index.push_str(&format!("Total files: {}\n\n", files.len()));
    
    for (i, path) in files.iter().enumerate() {
        let name = path.file_name().unwrap().to_string_lossy();
        let content = fs::read_to_string(path)?;
        let lines = content.lines().count();
        let size = content.len();
        
        // Extract purpose from comments
        let purpose = content.lines()
            .find(|l| l.starts_with("//") && !l.starts_with("///"))
            .map(|l| l.trim_start_matches("//").trim())
            .unwrap_or("No description");
        
        // Count functions
        let fn_count = content.matches("fn ").count();
        
        // Check for main
        let has_main = content.contains("fn main");
        
        println!("{:2}. {} ({} lines, {} bytes)", i+1, name, lines, size);
        println!("    Purpose: {}", purpose);
        println!("    Functions: {}, Main: {}\n", fn_count, has_main);
        
        index.push_str(&format!("## {}. {}\n\n", i+1, name));
        index.push_str(&format!("- **Lines**: {}\n", lines));
        index.push_str(&format!("- **Size**: {} bytes\n", size));
        index.push_str(&format!("- **Purpose**: {}\n", purpose));
        index.push_str(&format!("- **Functions**: {}\n", fn_count));
        index.push_str(&format!("- **Executable**: {}\n\n", has_main));
    }
    
    fs::write("FILE_INDEX.md", index)?;
    println!("✅ Saved: FILE_INDEX.md");
    
    Ok(())
}
