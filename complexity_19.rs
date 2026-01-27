use std::thread;
fn main() {
    let handle = thread::spawn(|| { 42 });
    println!("{}", handle.join().unwrap());
}