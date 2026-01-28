// Layer 21 - Monster Prime 17 (Genus 0)
fn main() {
    let layer = 21;
    let prime = 17;
    let sub_level = 1;
    let cycles = (layer + 1) * 1000 + (layer * layer) * 10;
    
    println!("Layer {}: prime={}, sub_level={}, cycles={}", 
             layer, prime, sub_level, cycles);
    
    // Simulate computation
    let mut sum = 0u64;
    for i in 0..cycles {
        sum = sum.wrapping_add(i as u64 * prime as u64);
    }
    
    println!("Result: {}", sum);
}
