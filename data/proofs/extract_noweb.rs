// Extract code from noweb literate document
use std::env;
use std::fs;

fn extract_code(content: &str) -> String {
    let mut code = Vec::new();
    let mut in_chunk = false;
    
    for line in content.lines() {
        if line.starts_with("<<") && line.contains(">>=") {
            in_chunk = true;
        } else if line.starts_with("@") {
            in_chunk = false;
        } else if in_chunk {
            // Skip chunk references (<<Name>> without =)
            if line.trim().starts_with("<<") && line.trim().ends_with(">>") {
                continue;
            }
            code.push(line);
        }
    }
    
    code.join("\n")
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: extract_noweb <file.nw>");
        std::process::exit(1);
    }
    
    let content = fs::read_to_string(&args[1])
        .expect("Failed to read file");
    
    let code = extract_code(&content);
    println!("{}", code);
}
