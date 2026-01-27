fn main() {
    let text = "test123";
    let has_digit = text.chars().any(|c| c.is_numeric());
    println!("{}", has_digit);
}