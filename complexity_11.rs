fn main() {
    let v: Vec<i32> = (0..100).collect();
    println!("{}", v.iter().sum::<i32>());
}