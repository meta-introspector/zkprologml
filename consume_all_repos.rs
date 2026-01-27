// Consume 1.5k repos using Rust + Oracle Busybox
use std::process::Command;
use std::fs;
use std::path::PathBuf;

#[derive(Debug)]
struct Repo {
    name: String,
    path: PathBuf,
    language: String,
    predicates: Vec<Predicate>,
}

#[derive(Debug)]
struct Predicate {
    name: String,
    arity: usize,
    complexity: u64,
    operations: Vec<String>,
}

// Prime complexity
fn prime(op: &str) -> u64 {
    match op {
        "measure" => 2, "compute" => 3, "verify" => 5, "store" => 7,
        "load" => 11, "transform" => 13, "prove" => 17, "witness" => 19,
        "consensus" => 23, "inject" => 29, _ => 3,
    }
}

// Oracle busybox call
fn oracle_call(cmd: &[&str]) -> String {
    let output = Command::new("./oracle_busybox")
        .args(cmd)
        .output()
        .expect("Oracle busybox failed");
    String::from_utf8_lossy(&output.stdout).to_string()
}

// List all repos via oracle
fn list_repos(org_path: &str) -> Vec<PathBuf> {
    fs::read_dir(org_path).ok()
        .map(|entries| entries
            .filter_map(|e| e.ok())
            .map(|e| e.path())
            .filter(|p| p.join(".git").exists())
            .collect())
        .unwrap_or_default()
}

// Detect language
fn detect_language(path: &PathBuf) -> String {
    if path.join("Cargo.toml").exists() { return "rust".into(); }
    if path.join("stack.yaml").exists() { return "haskell".into(); }
    if path.join("default.nix").exists() { return "nix".into(); }
    
    // Check for .pl files
    if let Ok(entries) = fs::read_dir(path) {
        for entry in entries.filter_map(|e| e.ok()) {
            if entry.path().extension().map(|s| s == "pl").unwrap_or(false) {
                return "prolog".into();
            }
        }
    }
    "unknown".into()
}

// Extract predicates
fn extract_predicates(path: &PathBuf, lang: &str) -> Vec<Predicate> {
    match lang {
        "prolog" => extract_prolog(path),
        "rust" => extract_rust(path),
        "haskell" => extract_haskell(path),
        _ => vec![],
    }
}

fn extract_prolog(path: &PathBuf) -> Vec<Predicate> {
    let mut preds = vec![];
    if let Ok(entries) = fs::read_dir(path) {
        for entry in entries.filter_map(|e| e.ok()) {
            if entry.path().extension().map(|s| s == "pl").unwrap_or(false) {
                preds.extend(parse_prolog_file(&entry.path()));
            }
        }
    }
    preds
}

fn parse_prolog_file(path: &std::path::Path) -> Vec<Predicate> {
    fs::read_to_string(path).ok()
        .map(|content| content.lines()
            .filter(|l| l.contains("(") && l.contains(":-"))
            .filter_map(|l| {
                let name = l.split('(').next()?.trim().to_string();
                let arity = l.matches(',').count() + 1;
                let ops = if l.contains("shell") || l.contains("process_create") { vec!["measure".to_string()] }
                    else if l.contains("assertz") { vec!["store".to_string()] }
                    else if l.contains("findall") { vec!["load".to_string()] }
                    else { vec!["compute".to_string()] };
                let complexity = ops.iter().map(|o| prime(o)).product();
                Some(Predicate { name, arity, complexity, operations: ops })
            })
            .collect())
        .unwrap_or_default()
}

fn extract_rust(path: &PathBuf) -> Vec<Predicate> {
    let mut preds = vec![];
    if let Ok(entries) = fs::read_dir(path.join("src")) {
        for entry in entries.filter_map(|e| e.ok()) {
            if entry.path().extension().map(|s| s == "rs").unwrap_or(false) {
                preds.extend(parse_rust_file(&entry.path()));
            }
        }
    }
    preds
}

fn parse_rust_file(path: &std::path::Path) -> Vec<Predicate> {
    fs::read_to_string(path).ok()
        .map(|content| content.lines()
            .filter(|l| l.trim().starts_with("fn ") || l.trim().starts_with("pub fn "))
            .filter_map(|l| {
                let name = l.split('(').next()?
                    .replace("fn ", "").replace("pub ", "").trim().to_string();
                let arity = l.matches(',').count() + 1;
                Some(Predicate { 
                    name, arity, complexity: 3, 
                    operations: vec!["compute".to_string()] 
                })
            })
            .collect())
        .unwrap_or_default()
}

fn extract_haskell(path: &PathBuf) -> Vec<Predicate> {
    let mut preds = vec![];
    if let Ok(entries) = fs::read_dir(path.join("src")) {
        for entry in entries.filter_map(|e| e.ok()) {
            if entry.path().extension().map(|s| s == "hs").unwrap_or(false) {
                preds.extend(parse_haskell_file(&entry.path()));
            }
        }
    }
    preds
}

fn parse_haskell_file(path: &std::path::Path) -> Vec<Predicate> {
    fs::read_to_string(path).ok()
        .map(|content| content.lines()
            .filter(|l| l.contains("::") && !l.trim().starts_with("--"))
            .filter_map(|l| {
                let name = l.split("::").next()?.trim().to_string();
                let arity = l.matches("->").count();
                Some(Predicate { 
                    name, arity, complexity: 3, 
                    operations: vec!["compute".to_string()] 
                })
            })
            .collect())
        .unwrap_or_default()
}

// Output Prolog
fn output_prolog(repos: &[Repo]) {
    println!("% Generated from {} repos", repos.len());
    println!(":- dynamic repo_predicate/5.");
    println!(":- dynamic repo_info/3.");
    println!();
    
    for repo in repos {
        println!("repo_info('{}', '{}', {}).", 
            repo.name, repo.language, repo.predicates.len());
        for pred in &repo.predicates {
            println!("repo_predicate('{}', '{}', {}, {}, {:?}).",
                repo.name, pred.name, pred.arity, pred.complexity, pred.operations);
        }
    }
    
    println!();
    println!("% Find equivalent predicates across repos");
    println!("equivalent(R1, P1, R2, P2) :-");
    println!("    repo_predicate(R1, P1, _, C, _),");
    println!("    repo_predicate(R2, P2, _, C, _),");
    println!("    R1 \\= R2.");
    println!();
    println!("% Universal call via prime complexity");
    println!("universal_call(SourceRepo, TargetRepo, Pred, Args) :-");
    println!("    repo_predicate(SourceRepo, Pred, _, C, _),");
    println!("    repo_predicate(TargetRepo, TargetPred, _, C, _),");
    println!("    format('~w.~w -> ~w.~w (complexity: ~w)~n', [SourceRepo, Pred, TargetRepo, TargetPred, C]).");
}

fn main() {
    println!("🔍 Consuming repos with Rust + Oracle Busybox");
    
    let org_path = std::env::args().nth(1).unwrap_or_else(|| ".".to_string());
    
    let repos: Vec<Repo> = list_repos(&org_path)
        .into_iter()
        .map(|path| {
            let name = path.file_name().unwrap().to_str().unwrap().to_string();
            let language = detect_language(&path);
            let predicates = extract_predicates(&path, &language);
            Repo { name, path, language, predicates }
        })
        .collect();
    
    let total: usize = repos.iter().map(|r| r.predicates.len()).sum();
    eprintln!("✅ {} repos, {} predicates", repos.len(), total);
    
    output_prolog(&repos);
}
