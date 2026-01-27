extern "C" { fn abs(x: i32) -> i32; }
fn main() {
    unsafe { println!("{}", abs(-42)); }
}