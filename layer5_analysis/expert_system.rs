use std::collections::HashMap;

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
