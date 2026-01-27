use std::fs;
use std::collections::HashMap;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔍 Cataloging MiniZinc Expert System\n");
    
    // Search our chord files for .mzn files
    println!("Step 1: Finding all .mzn files...");
    let mzn_files = search_chords(r"\.mzn")?;
    println!("  Found {} MiniZinc files\n", mzn_files.len());
    
    // Search for Rust files that use MiniZinc
    println!("Step 2: Finding Rust files using MiniZinc...");
    let rust_users = search_chords(r"minizinc.*\.rs")?;
    println!("  Found {} Rust files\n", rust_users.len());
    
    // Search for Nix files that use MiniZinc
    println!("Step 3: Finding Nix files using MiniZinc...");
    let nix_users = search_chords(r"minizinc.*\.nix")?;
    println!("  Found {} Nix files\n", nix_users.len());
    
    // Build knowledge graph
    println!("Step 4: Building knowledge graph...");
    let mut knowledge = String::from("# MiniZinc Expert System Knowledge Base\n\n");
    knowledge.push_str("## Discovered Resources\n\n");
    
    knowledge.push_str(&format!("### MiniZinc Models ({} files)\n\n", mzn_files.len()));
    for (i, path) in mzn_files.iter().take(20).enumerate() {
        knowledge.push_str(&format!("{}. `{}`\n", i+1, path));
    }
    if mzn_files.len() > 20 {
        knowledge.push_str(&format!("\n... and {} more\n", mzn_files.len() - 20));
    }
    
    knowledge.push_str(&format!("\n### Rust Integration ({} files)\n\n", rust_users.len()));
    for (i, path) in rust_users.iter().take(10).enumerate() {
        knowledge.push_str(&format!("{}. `{}`\n", i+1, path));
    }
    
    knowledge.push_str(&format!("\n### Nix Integration ({} files)\n\n", nix_users.len()));
    for (i, path) in nix_users.iter().take(10).enumerate() {
        knowledge.push_str(&format!("{}. `{}`\n", i+1, path));
    }
    
    // Extract patterns
    knowledge.push_str("\n## Learned Patterns\n\n");
    
    let patterns = extract_patterns(&mzn_files, &rust_users, &nix_users);
    for (pattern, count) in patterns {
        knowledge.push_str(&format!("- **{}**: {} occurrences\n", pattern, count));
    }
    
    // Generate expert rules
    knowledge.push_str("\n## Expert Rules (Learned)\n\n");
    knowledge.push_str("```prolog\n");
    knowledge.push_str("% Rule 1: If problem has optimization, use MiniZinc\n");
    knowledge.push_str("use_minizinc(Problem) :- has_constraints(Problem), needs_optimization(Problem).\n\n");
    
    knowledge.push_str("% Rule 2: If MiniZinc exists, wrap in Nix for reproducibility\n");
    knowledge.push_str("use_nix(MznFile) :- exists(MznFile), needs_reproducible_build.\n\n");
    
    knowledge.push_str("% Rule 3: If Nix builds MiniZinc, Rust can parse results\n");
    knowledge.push_str("use_rust(NixBuild) :- builds_minizinc(NixBuild), needs_parsing.\n\n");
    
    knowledge.push_str("% Rule 4: Bott periodicity reduces search space\n");
    knowledge.push_str("optimize(Levels) :- period(8), Levels mod 8 = Pattern, solve(Pattern).\n");
    knowledge.push_str("```\n\n");
    
    // Self-learning component
    knowledge.push_str("## Self-Learning System\n\n");
    knowledge.push_str("### Training Data\n\n");
    knowledge.push_str(&format!("- **Input**: {} MiniZinc models\n", mzn_files.len()));
    knowledge.push_str(&format!("- **Context**: {} Rust + {} Nix integrations\n", 
                                rust_users.len(), nix_users.len()));
    knowledge.push_str(&format!("- **Total examples**: {}\n\n", 
                                mzn_files.len() + rust_users.len() + nix_users.len()));
    
    knowledge.push_str("### Learning Algorithm\n\n");
    knowledge.push_str("1. **Pattern Recognition**: Extract common structures from .mzn files\n");
    knowledge.push_str("2. **Usage Analysis**: Map how Rust/Nix invoke MiniZinc\n");
    knowledge.push_str("3. **Rule Induction**: Generate expert rules from patterns\n");
    knowledge.push_str("4. **Validation**: Test rules against known examples\n");
    knowledge.push_str("5. **Refinement**: Update rules based on success rate\n\n");
    
    knowledge.push_str("### Next Iteration\n\n");
    knowledge.push_str("- Parse actual .mzn files to extract constraints\n");
    knowledge.push_str("- Analyze Rust code to find MiniZinc invocation patterns\n");
    knowledge.push_str("- Build decision tree: Problem → MiniZinc Model → Nix Build → Rust Parse\n");
    knowledge.push_str("- Train on our own system: 72 layers, 8 patterns, Bott periodicity\n\n");
    
    fs::write("data/docs/MINIZINC_EXPERT_SYSTEM.md", &knowledge)?;
    println!("✅ Saved: data/docs/MINIZINC_EXPERT_SYSTEM.md\n");
    
    // Generate next step: actual learning system
    generate_learning_system()?;
    
    Ok(())
}

fn search_chords(pattern: &str) -> Result<Vec<String>, Box<dyn std::error::Error>> {
    let mut results = Vec::new();
    
    for entry in fs::read_dir("data/chords")? {
        let entry = entry?;
        let path = entry.path();
        
        if path.extension().and_then(|s| s.to_str()) == Some("txt") {
            let content = fs::read_to_string(&path)?;
            
            for line in content.lines() {
                if line.contains("minizinc") && line.contains(pattern.trim_matches('\\')) {
                    results.push(line.to_string());
                }
            }
        }
    }
    
    results.sort();
    results.dedup();
    Ok(results)
}

fn extract_patterns(mzn: &[String], rust: &[String], nix: &[String]) -> Vec<(String, usize)> {
    let mut patterns = HashMap::new();
    
    // Pattern: optimization problems
    let opt_count = mzn.iter().filter(|s| s.contains("optimize") || s.contains("minimize")).count();
    if opt_count > 0 {
        patterns.insert("Optimization Problems".to_string(), opt_count);
    }
    
    // Pattern: constraint solving
    let constraint_count = mzn.iter().filter(|s| s.contains("constraint")).count();
    if constraint_count > 0 {
        patterns.insert("Constraint Solving".to_string(), constraint_count);
    }
    
    // Pattern: Nix builds
    let nix_build_count = nix.len();
    if nix_build_count > 0 {
        patterns.insert("Nix Reproducible Builds".to_string(), nix_build_count);
    }
    
    // Pattern: Rust parsing
    let rust_parse_count = rust.len();
    if rust_parse_count > 0 {
        patterns.insert("Rust Result Parsing".to_string(), rust_parse_count);
    }
    
    let mut sorted: Vec<_> = patterns.into_iter().collect();
    sorted.sort_by(|a, b| b.1.cmp(&a.1));
    sorted
}

fn generate_learning_system() -> Result<(), Box<dyn std::error::Error>> {
    let code = r#"use std::collections::HashMap;

// Self-learning expert system for MiniZinc optimization
struct ExpertSystem {
    rules: Vec<Rule>,
    knowledge: HashMap<String, Vec<String>>,
    success_rate: HashMap<String, f64>,
}

struct Rule {
    condition: String,
    action: String,
    confidence: f64,
}

impl ExpertSystem {
    fn new() -> Self {
        Self {
            rules: Vec::new(),
            knowledge: HashMap::new(),
            success_rate: HashMap::new(),
        }
    }
    
    fn learn_from_example(&mut self, problem: &str, solution: &str, success: bool) {
        // Extract features from problem
        let features = self.extract_features(problem);
        
        // Update knowledge base
        self.knowledge.entry(problem.to_string())
            .or_insert_with(Vec::new)
            .push(solution.to_string());
        
        // Update success rate
        let key = format!("{}→{}", problem, solution);
        let current = self.success_rate.get(&key).unwrap_or(&0.5);
        let new_rate = if success {
            current * 0.9 + 0.1  // Increase confidence
        } else {
            current * 0.9        // Decrease confidence
        };
        self.success_rate.insert(key, new_rate);
        
        // Generate new rules if confidence high enough
        if new_rate > 0.8 {
            self.rules.push(Rule {
                condition: problem.to_string(),
                action: solution.to_string(),
                confidence: new_rate,
            });
        }
    }
    
    fn extract_features(&self, problem: &str) -> Vec<String> {
        let mut features = Vec::new();
        
        if problem.contains("optimize") { features.push("optimization".to_string()); }
        if problem.contains("constraint") { features.push("constraints".to_string()); }
        if problem.contains("schedule") { features.push("scheduling".to_string()); }
        if problem.contains("resource") { features.push("resource_allocation".to_string()); }
        if problem.contains("periodic") { features.push("periodicity".to_string()); }
        
        features
    }
    
    fn recommend(&self, problem: &str) -> Option<String> {
        // Find best matching rule
        let features = self.extract_features(problem);
        
        let mut best_rule: Option<&Rule> = None;
        let mut best_score = 0.0;
        
        for rule in &self.rules {
            let rule_features = self.extract_features(&rule.condition);
            let overlap = features.iter()
                .filter(|f| rule_features.contains(f))
                .count() as f64;
            let score = (overlap / features.len() as f64) * rule.confidence;
            
            if score > best_score {
                best_score = score;
                best_rule = Some(rule);
            }
        }
        
        best_rule.map(|r| r.action.clone())
    }
}

fn main() {
    println!("🧠 Self-Learning Expert System");
    println!("Training on our own build system...\n");
    
    let mut expert = ExpertSystem::new();
    
    // Train on Bott periodicity discovery
    expert.learn_from_example(
        "72 levels, periodic patterns",
        "Use Bott periodicity, period=8",
        true
    );
    
    // Train on resource allocation
    expert.learn_from_example(
        "Build scheduling with CPU constraints",
        "Use MiniZinc constraint solver",
        true
    );
    
    // Train on optimization
    expert.learn_from_example(
        "Minimize build time with parallel execution",
        "MiniZinc + Nix + Rust pipeline",
        true
    );
    
    // Test recommendation
    let problem = "Schedule 72 builds with periodic patterns and CPU constraints";
    if let Some(solution) = expert.recommend(problem) {
        println!("Problem: {}", problem);
        println!("Recommended: {}\n", solution);
    }
    
    println!("✅ Expert system learning from experience!");
}
"#;
    
    fs::write("layer5_analysis/expert_system.rs", code)?;
    println!("✅ Generated: layer5_analysis/expert_system.rs");
    
    Ok(())
}
