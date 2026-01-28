// Generate 71 clean LLM prompts in Rust

use std::fs::{create_dir_all, File};
use std::io::Write;

const PRIMES: [u64; 20] = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71];

fn get_domain(prime: u64) -> (&'static str, &'static str) {
    match prime {
        2 => ("types", "int, bool, char"),
        3 => ("operators", "+, -, *, /"),
        5 => ("variables", "x, y, z"),
        7 => ("control", "if, while, for"),
        11 => ("functions", "def, fn, lambda"),
        13 => ("pointers", "*ptr, &ref"),
        17 => ("structures", "struct, record"),
        19 => ("arrays", "[], vector"),
        23 => ("memory", "malloc, free"),
        29 => ("optimization", "SSA, inlining"),
        31 => ("output", "print, write"),
        37 => ("loops", "loop, iterate"),
        41 => ("machine", "asm, linking"),
        43 => ("safety", "borrow, lifetime"),
        47 => ("network", "tcp, http"),
        53 => ("generics", "<T>, impl"),
        59 => ("macros", "macro!, quote"),
        61 => ("reflection", "typeof, meta"),
        67 => ("metaprogramming", "eval, compile"),
        71 => ("universe", "Type, Kind, Universe"),
        _ => ("unknown", ""),
    }
}

fn get_flavor(prime: u64) -> &'static str {
    match prime {
        2 => "Rust: pub enum Type { Int, Bool, Char }",
        3 => "Prolog: operator(+, 3). operator(*, 5).",
        5 => "Lean4: def variable (α : Type) : Type := α",
        7 => "LLVM: br i1 %cond, label %then, label %else",
        11 => "Rust: fn map<F>(self, f: F) where F: Fn(T) -> U",
        13 => "C: int *ptr = &value; *ptr = 42;",
        17 => "Rust: struct Point { x: i32, y: i32 }",
        19 => "Prolog: array([1,2,3,4,5]).",
        23 => "Rust: Box::new(value)",
        29 => "LLVM: %opt = add nsw i32 %a, %b",
        31 => "Rust: println!(\"{}\", value);",
        37 => "Rust: for item in collection { process(item); }",
        41 => "Assembly: mov rax, [rbp-8]",
        43 => "Rust: fn borrow<'a>(x: &'a T) -> &'a T",
        47 => "Rust: tokio::spawn(async { tcp_server().await })",
        53 => "Rust: impl<T: Clone> MyTrait for T",
        59 => "Rust: macro_rules! vec { ($($x:expr),*) => { ... } }",
        61 => "Rust: std::any::type_name::<T>()",
        67 => "Prolog: term_expansion((Head :- Body), Expanded)",
        71 => "Lean4: universe u; Type u : Type (u+1)",
        _ => "",
    }
}

fn generate_moonshine() -> std::io::Result<()> {
    create_dir_all("generated/data-moonshine")?;
    let mut file = File::create("generated/data-moonshine/prompts.jsonl")?;
    
    for &prime in &PRIMES {
        let (domain, desc) = get_domain(prime);
        let flavor = get_flavor(prime);
        
        let prompt = format!(
            "You are a zkPrologML expert. Prime {} represents {}.\\n\\nDescription: {}\\n\\nTask: Implement {} using prime signature {}. Show how this maps to the Monster group lattice.\\n\\nCode flavor: {}\\n\\nGenerate a complete implementation in Rust, Prolog, and Lean4.",
            prime, domain, desc, domain, prime, flavor
        );
        
        writeln!(file, "{{\"prime\":{},\"domain\":\"{}\",\"prompt\":\"{}\",\"dataset\":\"moonshine\"}}",
                 prime, domain, prompt.replace("\"", "\\\"").replace("\n", "\\n"))?;
    }
    
    println!("✅ Moonshine: generated/data-moonshine/prompts.jsonl");
    Ok(())
}

fn generate_const71() -> std::io::Result<()> {
    create_dir_all("generated/data-const71")?;
    let mut file = File::create("generated/data-const71/constants.jsonl")?;
    
    for &prime in &PRIMES {
        let (domain, desc) = get_domain(prime);
        
        writeln!(file, "{{\"prime\":{},\"domain\":\"{}\",\"description\":\"{}\",\"constant\":true,\"dataset\":\"const71\"}}",
                 prime, domain, desc)?;
    }
    
    println!("✅ Const71: generated/data-const71/constants.jsonl");
    Ok(())
}

fn main() -> std::io::Result<()> {
    println!("\n🌌 GENERATING 71 CLEAN PROMPTS (Rust)\n");
    generate_moonshine()?;
    generate_const71()?;
    println!("\n✨ Datasets ready!\n");
    Ok(())
}
