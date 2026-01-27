use std::collections::HashMap;
fn main() {
    let mut map = HashMap::new();
    map.insert("key", 42);
    println!("{}", map.get("key").unwrap());
}