use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use std::thread;
use std::fs;

fn fib(n: u32) -> u32 {
    if n <= 1 { n } else { fib(n-1) + fib(n-2) }
}

fn main() {
    let data = Arc::new(Mutex::new(HashMap::new()));
    let handles: Vec<_> = (0..4).map(|i| {
        let d = data.clone();
        thread::spawn(move || {
            d.lock().unwrap().insert(i, fib(i + 10));
        })
    }).collect();
    
    for h in handles { h.join().unwrap(); }
    
    fs::write("/tmp/result.txt", format!("{:?}", *data.lock().unwrap())).unwrap();
    println!("Done");
}