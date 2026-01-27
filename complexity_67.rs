fn main() {
    let x = 42;
    let ptr = &x as *const i32;
    unsafe { println!("{}", *ptr); }
}