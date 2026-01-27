use std::sync::{Arc, Mutex};
fn main() {
    let data = Arc::new(Mutex::new(0));
    let d = data.clone();
    *d.lock().unwrap() = 42;
    println!("{}", *data.lock().unwrap());
}