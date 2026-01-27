use std::fs;
use std::path::{Path, PathBuf};
use std::sync::{Arc, Mutex};
use std::sync::mpsc::{channel, Sender, Receiver};
use std::thread;
use std::collections::HashMap;

const NUM_UMBERTOS: usize = 24;

#[derive(Debug, Clone)]
struct IndexCard {
    location: String,      // Library location
    title: String,         // File/directory name
    content_hash: u64,     // Hash of content
    references: Vec<String>, // Links to other cards
    chord: usize,          // Harmonic classification
    discovered_by: usize,  // Which Umberto found it
}

#[derive(Debug, Clone)]
struct Letter {
    from: usize,
    to: usize,
    cards: Vec<IndexCard>,
    timestamp: u128,
}

struct UmbertoEco {
    id: usize,
    library_path: PathBuf,
    index_cards: Arc<Mutex<Vec<IndexCard>>>,
    mailbox: Receiver<Letter>,
    post_office: Sender<Letter>,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("📚 Summoning 24 Umberto Eco Scholars\n");
    
    // Define libraries to explore
    let libraries = vec![
        "submodules",
        "/home/mdupont/.cargo/registry/src",
        "/mnt/data1/nix/vendor/rust",
        "/mnt/data1/meta-introspector",
    ];
    
    // Create post office for letter exchange
    let (post_tx, post_rx): (Sender<Letter>, Receiver<Letter>) = channel();
    let post_rx = Arc::new(Mutex::new(post_rx));
    
    // Create individual mailboxes
    let mut mailboxes = Vec::new();
    let mut senders = Vec::new();
    
    for _ in 0..NUM_UMBERTOS {
        let (tx, rx) = channel();
        mailboxes.push(rx);
        senders.push(tx);
    }
    
    let all_cards = Arc::new(Mutex::new(Vec::new()));
    
    // Spawn Umberto Eco scholars
    let mut handles = vec![];
    
    for id in 0..NUM_UMBERTOS {
        let library = libraries[id % libraries.len()].to_string();
        let mailbox = mailboxes.remove(0);
        let post_office = post_tx.clone();
        let cards = Arc::clone(&all_cards);
        let senders_clone = senders.clone();
        
        let handle = thread::spawn(move || {
            umberto_explore(id, library, mailbox, post_office, cards, senders_clone);
        });
        
        handles.push(handle);
    }
    
    drop(post_tx);
    
    // Post office: route letters
    let post_handle = thread::spawn(move || {
        let rx = post_rx.lock().unwrap();
        let mut letter_count = 0;
        
        while let Ok(letter) = rx.recv() {
            letter_count += 1;
            if letter_count % 10 == 0 {
                println!("📬 Post Office: {} letters delivered", letter_count);
            }
            
            if letter.to < senders.len() {
                let _ = senders[letter.to].send(letter);
            }
        }
        
        println!("📬 Post Office closed: {} total letters", letter_count);
    });
    
    // Wait for scholars
    for handle in handles {
        handle.join().unwrap();
    }
    
    post_handle.join().unwrap();
    
    // Analyze collected knowledge
    let cards = all_cards.lock().unwrap();
    println!("\n📊 Knowledge Collected:");
    println!("   Total index cards: {}", cards.len());
    
    // Group by chord
    let mut chord_counts: HashMap<usize, usize> = HashMap::new();
    for card in cards.iter() {
        *chord_counts.entry(card.chord).or_insert(0) += 1;
    }
    
    println!("\n🎼 Cards by Chord:");
    for chord in 0..24 {
        if let Some(&count) = chord_counts.get(&chord) {
            println!("   Chord {}: {} cards", chord, count);
        }
    }
    
    // Find most referenced cards
    let mut ref_counts: HashMap<String, usize> = HashMap::new();
    for card in cards.iter() {
        for reference in &card.references {
            *ref_counts.entry(reference.clone()).or_insert(0) += 1;
        }
    }
    
    let mut top_refs: Vec<_> = ref_counts.iter().collect();
    top_refs.sort_by_key(|(_, &count)| std::cmp::Reverse(count));
    
    println!("\n🔗 Most Referenced:");
    for (title, count) in top_refs.iter().take(10) {
        println!("   {}: {} references", title, count);
    }
    
    // Save collected knowledge
    let mut output = String::from("# Umberto Eco's Collected Index Cards\n\n");
    for card in cards.iter().take(100) {
        output.push_str(&format!(
            "## {}\n- Location: {}\n- Chord: {}\n- Discovered by: Umberto #{}\n- References: {}\n\n",
            card.title,
            card.location,
            card.chord,
            card.discovered_by,
            card.references.len()
        ));
    }
    
    fs::write("umberto_index_cards.md", output)?;
    println!("\n✅ Saved: umberto_index_cards.md");
    
    Ok(())
}

fn umberto_explore(
    id: usize,
    library: String,
    mailbox: Receiver<Letter>,
    post_office: Sender<Letter>,
    all_cards: Arc<Mutex<Vec<IndexCard>>>,
    peers: Vec<Sender<Letter>>,
) {
    println!("👨‍🏫 Umberto #{} exploring: {}", id, library);
    
    let mut my_cards = Vec::new();
    let start = std::time::Instant::now();
    
    // Explore library
    if let Ok(entries) = explore_directory(&library, id, 3) {
        my_cards.extend(entries);
    }
    
    // Also check for .txt chord files
    for chord in 0..24 {
        let chord_file = format!("github_{:02}.txt", chord);
        if let Ok(content) = fs::read_to_string(&chord_file) {
            for (i, line) in content.lines().enumerate().take(10) {
                if line.ends_with(".rs") || line.ends_with(".toml") {
                    my_cards.push(IndexCard {
                        location: chord_file.clone(),
                        title: line.to_string(),
                        content_hash: hash_string(line),
                        references: extract_references(line),
                        chord: chord,
                        discovered_by: id,
                    });
                }
            }
        }
    }
    
    println!("👨‍🏫 Umberto #{} found {} cards in {:?}", id, my_cards.len(), start.elapsed());
    
    // Add to global collection
    {
        let mut cards = all_cards.lock().unwrap();
        cards.extend(my_cards.clone());
    }
    
    // Write letters to peers (trade knowledge)
    if !my_cards.is_empty() {
        let cards_per_letter = (my_cards.len() / 3).max(1);
        
        for peer_id in 0..NUM_UMBERTOS {
            if peer_id != id && peer_id < peers.len() {
                let start_idx = (peer_id * cards_per_letter) % my_cards.len();
                let end_idx = (start_idx + cards_per_letter).min(my_cards.len());
                
                let letter = Letter {
                    from: id,
                    to: peer_id,
                    cards: my_cards[start_idx..end_idx].to_vec(),
                    timestamp: start.elapsed().as_millis(),
                };
                
                let _ = post_office.send(letter);
            }
        }
    }
    
    // Read incoming letters
    let mut letters_received = 0;
    while let Ok(letter) = mailbox.try_recv() {
        letters_received += 1;
        
        // Learn from peer's discoveries
        for card in letter.cards {
            if card.chord == id % 24 {
                // This card resonates with my chord!
                let mut cards = all_cards.lock().unwrap();
                cards.push(card);
            }
        }
    }
    
    if letters_received > 0 {
        println!("📨 Umberto #{} received {} letters", id, letters_received);
    }
}

fn explore_directory(path: &str, discoverer: usize, depth: usize) -> Result<Vec<IndexCard>, std::io::Error> {
    if depth == 0 {
        return Ok(Vec::new());
    }
    
    let mut cards = Vec::new();
    
    if let Ok(entries) = fs::read_dir(path) {
        for entry in entries.take(50) {
            if let Ok(entry) = entry {
                let path = entry.path();
                let name = entry.file_name().to_string_lossy().to_string();
                
                if path.is_file() && (name.ends_with(".rs") || name.ends_with(".toml") || name == "README.md") {
                    let hash = hash_string(&path.to_string_lossy());
                    let chord = (hash % 24) as usize;
                    
                    cards.push(IndexCard {
                        location: path.parent().unwrap_or(Path::new("")).to_string_lossy().to_string(),
                        title: name.clone(),
                        content_hash: hash,
                        references: extract_references(&name),
                        chord,
                        discovered_by: discoverer,
                    });
                } else if path.is_dir() && !name.starts_with('.') {
                    if let Ok(sub_cards) = explore_directory(&path.to_string_lossy(), discoverer, depth - 1) {
                        cards.extend(sub_cards);
                    }
                }
            }
        }
    }
    
    Ok(cards)
}

fn hash_string(s: &str) -> u64 {
    s.bytes().fold(0u64, |acc, b| acc.wrapping_mul(31).wrapping_add(b as u64))
}

fn extract_references(name: &str) -> Vec<String> {
    let mut refs = Vec::new();
    
    // Extract common patterns
    if name.contains("github") { refs.push("github".to_string()); }
    if name.contains("search") { refs.push("search".to_string()); }
    if name.contains("index") { refs.push("index".to_string()); }
    if name.contains("cargo") { refs.push("cargo".to_string()); }
    
    refs
}
