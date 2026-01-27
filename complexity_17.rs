use std::fs;
fn main() {
    fs::write("/tmp/test.txt", "data").unwrap();
    let data = fs::read_to_string("/tmp/test.txt").unwrap();
    println!("{}", data);
}