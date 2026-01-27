use std::process::{Command, Stdio};
use std::sync::{Arc, Mutex};
use std::sync::mpsc::{channel, Sender, Receiver};
use std::thread;
use std::time::Instant;

const NUM_WORKERS: usize = 24;
const RAM_PER_WORKER: usize = 1250; // MB (30GB / 24)

#[derive(Debug, Clone)]
struct SearchTask {
    term: String,
    depth: u32,
    chord: usize,
}

#[derive(Debug)]
struct SearchResult {
    term: String,
    files_found: usize,
    time_ms: u128,
    cpu_cycles: u64,
    worker_id: usize,
}

#[derive(Debug)]
struct TradeOffer {
    from_worker: usize,
    to_worker: usize,
    task: SearchTask,
    priority: f64,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🌐 Multi-Process Trading Search System");
    println!("   Workers: {}", NUM_WORKERS);
    println!("   RAM per worker: {}MB\n", RAM_PER_WORKER);
    
    // Create task queue
    let terms = vec!["github", "search", "index", "crawler", "scraper", "octocrab", "fuzzy", "fulltext"];
    let mut tasks = Vec::new();
    
    for (i, term) in terms.iter().enumerate() {
        for chord in 0..24 {
            tasks.push(SearchTask {
                term: term.to_string(),
                depth: 10,
                chord,
            });
        }
    }
    
    println!("📋 Total tasks: {}", tasks.len());
    
    // Create channels for trading
    let (trade_tx, trade_rx): (Sender<TradeOffer>, Receiver<TradeOffer>) = channel();
    let (result_tx, result_rx): (Sender<SearchResult>, Receiver<SearchResult>) = channel();
    
    let tasks = Arc::new(Mutex::new(tasks));
    let trade_rx = Arc::new(Mutex::new(trade_rx));
    
    // Spawn workers
    let mut handles = vec![];
    
    for worker_id in 0..NUM_WORKERS {
        let tasks = Arc::clone(&tasks);
        let trade_tx = trade_tx.clone();
        let trade_rx = Arc::clone(&trade_rx);
        let result_tx = result_tx.clone();
        
        let handle = thread::spawn(move || {
            worker_loop(worker_id, tasks, trade_tx, trade_rx, result_tx);
        });
        
        handles.push(handle);
    }
    
    drop(trade_tx);
    drop(result_tx);
    
    // Collect results
    let collector = thread::spawn(move || {
        let mut results = Vec::new();
        while let Ok(result) = result_rx.recv() {
            println!("✅ Worker {} completed {} in {}ms", 
                result.worker_id, result.term, result.time_ms);
            results.push(result);
        }
        results
    });
    
    // Wait for workers
    for handle in handles {
        handle.join().unwrap();
    }
    
    let results = collector.join().unwrap();
    
    // Analyze performance
    println!("\n📊 Performance Summary:");
    println!("   Total tasks completed: {}", results.len());
    
    let total_time: u128 = results.iter().map(|r| r.time_ms).sum();
    let avg_time = total_time / results.len() as u128;
    println!("   Average time per task: {}ms", avg_time);
    
    let total_files: usize = results.iter().map(|r| r.files_found).sum();
    println!("   Total files found: {}", total_files);
    
    // Worker efficiency
    let mut worker_times = vec![0u128; NUM_WORKERS];
    for result in &results {
        worker_times[result.worker_id] += result.time_ms;
    }
    
    println!("\n⚖️  Worker Load Balance:");
    for (id, time) in worker_times.iter().enumerate() {
        let pct = (*time as f64 / total_time as f64) * 100.0;
        println!("   Worker {}: {}ms ({:.1}%)", id, time, pct);
    }
    
    Ok(())
}

fn worker_loop(
    worker_id: usize,
    tasks: Arc<Mutex<Vec<SearchTask>>>,
    trade_tx: Sender<TradeOffer>,
    trade_rx: Arc<Mutex<Receiver<TradeOffer>>>,
    result_tx: Sender<SearchResult>,
) {
    loop {
        // Try to get a task
        let task = {
            let mut task_queue = tasks.lock().unwrap();
            task_queue.pop()
        };
        
        match task {
            Some(task) => {
                // Check if we should trade this task
                if should_trade(&task, worker_id) {
                    let offer = TradeOffer {
                        from_worker: worker_id,
                        to_worker: (worker_id + 1) % NUM_WORKERS,
                        task: task.clone(),
                        priority: calculate_priority(&task),
                    };
                    let _ = trade_tx.send(offer);
                }
                
                // Execute task
                let result = execute_search_task(worker_id, &task);
                let _ = result_tx.send(result);
            }
            None => {
                // No more tasks, check for trades
                if let Ok(rx) = trade_rx.lock() {
                    if let Ok(offer) = rx.try_recv() {
                        if offer.to_worker == worker_id {
                            // Accept trade
                            let result = execute_search_task(worker_id, &offer.task);
                            let _ = result_tx.send(result);
                            continue;
                        }
                    }
                }
                break;
            }
        }
    }
}

fn should_trade(task: &SearchTask, worker_id: usize) -> bool {
    // Trade if task chord doesn't match worker affinity
    task.chord % NUM_WORKERS != worker_id
}

fn calculate_priority(task: &SearchTask) -> f64 {
    // Higher priority for high-resonance terms
    match task.term.as_str() {
        "search" => 131.17,
        "fulltext" => 112.82,
        "fuzzy" => 30.15,
        "scraper" => 15.82,
        "index" => 14.44,
        "crawler" => 10.42,
        "github" => 8.53,
        "octocrab" => 8.38,
        _ => 1.0,
    }
}

fn execute_search_task(worker_id: usize, task: &SearchTask) -> SearchResult {
    let start = Instant::now();
    
    // Execute plocate for this chord
    let chord_file = format!("{}_{:02}.txt", task.term, task.chord);
    
    let files_found = std::fs::read_to_string(&chord_file)
        .map(|content| content.lines().count())
        .unwrap_or(0);
    
    let time_ms = start.elapsed().as_millis();
    
    SearchResult {
        term: task.term.clone(),
        files_found,
        time_ms,
        cpu_cycles: 0,
        worker_id,
    }
}
