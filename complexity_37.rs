use std::process::Command;
fn main() {
    let output = Command::new("echo").arg("test").output().unwrap();
    println!("{}", String::from_utf8_lossy(&output.stdout));
}