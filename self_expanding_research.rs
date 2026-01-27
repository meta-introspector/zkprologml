use std::fs;
use std::collections::{HashSet, HashMap};
use rand::Rng;

#[derive(Debug, Clone)]
struct ResearchIdea {
    terms: Vec<String>,
    novelty: f64,
    lmfdb_distance: f64,
}

struct SelfExpandingSystem {
    known_terms: HashSet<String>,
    index_cards: Vec<String>,
    research_ideas: Vec<ResearchIdea>,
    lmfdb_terms: HashSet<String>,
}

impl SelfExpandingSystem {
    fn new() -> Result<Self, Box<dyn std::error::Error>> {
        // Load existing knowledge
        let cards = fs::read_to_string("umberto_index_cards.md")
            .or_else(|_| fs::read_to_string("umberto_index_cards_expanded.md"))?;
        
        let known_terms: HashSet<String> = cards.lines()
            .filter(|l| l.starts_with("- ") || l.starts_with("## "))
            .map(|l| l.trim_start_matches("- ").trim_start_matches("## ").to_string())
            .collect();
        
        // LMFDB closure terms
        let lmfdb_terms: HashSet<String> = vec![
            "elliptic_curve", "modular_form", "l_function", "galois_representation",
            "conductor", "rank", "torsion", "isogeny", "j_invariant", "discriminant",
            "hecke_operator", "newform", "cusp_form", "eisenstein_series",
            "shimura_curve", "hilbert_modular_form", "siegel_modular_form",
            "automorphic_representation", "langlands_correspondence", "local_factor",
        ].iter().map(|s| s.to_string()).collect();
        
        Ok(SelfExpandingSystem {
            known_terms: known_terms.clone(),
            index_cards: known_terms.into_iter().collect(),
            research_ideas: Vec::new(),
            lmfdb_terms,
        })
    }
    
    fn compute_closure_distance(&self) -> f64 {
        let overlap: usize = self.known_terms.intersection(&self.lmfdb_terms).count();
        let total = self.lmfdb_terms.len();
        1.0 - (overlap as f64 / total as f64)
    }
    
    fn sample_and_combine(&self, rng: &mut impl Rng) -> ResearchIdea {
        // Sample 2-3 random terms from cards
        let n = rng.gen_range(2..=3);
        let mut terms = Vec::new();
        
        for _ in 0..n {
            if !self.index_cards.is_empty() {
                let idx = rng.gen_range(0..self.index_cards.len());
                terms.push(self.index_cards[idx].clone());
            }
        }
        
        // Compute novelty: how many terms are NOT in LMFDB?
        let novel_count = terms.iter().filter(|t| !self.lmfdb_terms.contains(*t)).count();
        let novelty = novel_count as f64 / terms.len() as f64;
        
        // Distance to LMFDB: how close are we?
        let lmfdb_distance = self.compute_closure_distance();
        
        ResearchIdea {
            terms,
            novelty,
            lmfdb_distance,
        }
    }
    
    fn generate_search_query(&self, idea: &ResearchIdea) -> String {
        idea.terms.join(" + ")
    }
    
    fn expand(&mut self, idea: &ResearchIdea) -> Vec<String> {
        // Simulate discovering new terms by combining existing ones
        let mut new_terms = Vec::new();
        
        for i in 0..idea.terms.len() {
            for j in i+1..idea.terms.len() {
                let combined = format!("{}_{}", idea.terms[i], idea.terms[j]);
                if !self.known_terms.contains(&combined) {
                    new_terms.push(combined.clone());
                    self.known_terms.insert(combined);
                }
            }
        }
        
        new_terms
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔬 Self-Expanding Research System");
    println!("   Sampling → Combining → Searching → Expanding\n");
    
    let mut system = SelfExpandingSystem::new()?;
    let mut rng = rand::thread_rng();
    
    println!("📊 Initial State:");
    println!("   Known terms: {}", system.known_terms.len());
    println!("   LMFDB terms: {}", system.lmfdb_terms.len());
    println!("   Distance to closure: {:.2}%\n", system.compute_closure_distance() * 100.0);
    
    // Expansion loop
    println!("🌱 Expansion Loop:");
    for iteration in 0..20 {
        // Sample and combine
        let idea = system.sample_and_combine(&mut rng);
        
        // Generate search query
        let query = system.generate_search_query(&idea);
        
        // Expand knowledge
        let new_terms = system.expand(&idea);
        
        // Update cards
        for term in &new_terms {
            system.index_cards.push(term.clone());
        }
        
        system.research_ideas.push(idea.clone());
        
        let distance = system.compute_closure_distance();
        
        println!("  Iter {}: '{}' → {} new terms (distance: {:.2}%)", 
            iteration + 1, query, new_terms.len(), distance * 100.0);
        
        // Check for closure
        if distance < 0.1 {
            println!("\n✨ LMFDB CLOSURE REACHED!");
            break;
        }
    }
    
    // Final state
    println!("\n📊 Final State:");
    println!("   Known terms: {}", system.known_terms.len());
    println!("   Research ideas: {}", system.research_ideas.len());
    println!("   Distance to closure: {:.2}%", system.compute_closure_distance() * 100.0);
    
    // Analyze research ideas
    println!("\n🔍 Top Research Ideas:");
    let mut sorted_ideas = system.research_ideas.clone();
    sorted_ideas.sort_by(|a, b| b.novelty.partial_cmp(&a.novelty).unwrap());
    
    for (i, idea) in sorted_ideas.iter().take(5).enumerate() {
        println!("  {}: {} (novelty: {:.2})", 
            i + 1, idea.terms.join(" + "), idea.novelty);
    }
    
    // Save expanded knowledge
    save_expanded_knowledge(&system)?;
    
    // Generate research roadmap
    generate_roadmap(&system)?;
    
    Ok(())
}

fn save_expanded_knowledge(system: &SelfExpandingSystem) -> Result<(), Box<dyn std::error::Error>> {
    let mut output = String::from("# Self-Expanded Knowledge Base\n\n");
    
    output.push_str(&format!("## Statistics\n"));
    output.push_str(&format!("- Total terms: {}\n", system.known_terms.len()));
    output.push_str(&format!("- Research ideas: {}\n", system.research_ideas.len()));
    output.push_str(&format!("- LMFDB closure: {:.1}%\n\n", (1.0 - system.compute_closure_distance()) * 100.0));
    
    output.push_str("## New Terms Discovered\n");
    let mut new_terms: Vec<_> = system.known_terms.iter()
        .filter(|t| !system.lmfdb_terms.contains(*t))
        .collect();
    new_terms.sort();
    
    for term in new_terms.iter().take(50) {
        output.push_str(&format!("- {}\n", term));
    }
    
    output.push_str("\n## Research Ideas Generated\n");
    for (i, idea) in system.research_ideas.iter().enumerate() {
        output.push_str(&format!("{}. {} (novelty: {:.2})\n", 
            i + 1, idea.terms.join(" + "), idea.novelty));
    }
    
    fs::write("expanded_knowledge.md", output)?;
    println!("\n✅ Saved: expanded_knowledge.md");
    
    Ok(())
}

fn generate_roadmap(system: &SelfExpandingSystem) -> Result<(), Box<dyn std::error::Error>> {
    let missing: Vec<_> = system.lmfdb_terms.difference(&system.known_terms).collect();
    
    let roadmap = format!(
        "# Research Roadmap to LMFDB Closure\n\
        \n\
        ## Current Progress\n\
        - Coverage: {:.1}%\n\
        - Missing terms: {}\n\
        \n\
        ## Missing LMFDB Terms\n\
        {}\n\
        \n\
        ## Next Steps\n\
        1. Search for missing terms in existing repos\n\
        2. Query LMFDB database for definitions\n\
        3. Generate new combinations from known terms\n\
        4. Expand Umberto's index cards\n\
        5. Iterate until closure\n\
        \n\
        ## Self-Expansion Strategy\n\
        - Sample existing cards\n\
        - Combine terms (A + B → A_B)\n\
        - Search for combinations\n\
        - Add discoveries to cards\n\
        - Repeat until LMFDB terms covered\n\
        \n\
        ## Closure Condition\n\
        ```\n\
        distance = 1 - |known ∩ LMFDB| / |LMFDB|\n\
        closure reached when distance < 0.1\n\
        ```\n\
        \n\
        The system expands itself by:\n\
        1. Sampling its own knowledge\n\
        2. Generating new research ideas\n\
        3. Searching for combinations\n\
        4. Discovering new terms\n\
        5. Adding to index cards\n\
        6. Measuring distance to LMFDB\n\
        7. Repeating until closure\n\
        \n\
        **The system grows its own understanding!**\n\
        ",
        (1.0 - system.compute_closure_distance()) * 100.0,
        missing.len(),
        missing.iter().map(|s| format!("- {}", s)).collect::<Vec<_>>().join("\n")
    );
    
    fs::write("research_roadmap.md", roadmap)?;
    println!("✅ Saved: research_roadmap.md");
    
    Ok(())
}
