use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};
fn main() {
    let mut hasher = DefaultHasher::new();
    "data".hash(&mut hasher);
    println!("{}", hasher.finish());
}