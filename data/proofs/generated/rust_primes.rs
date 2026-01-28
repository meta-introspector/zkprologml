
/// Prime number checker (Monster group primes)
pub fn is_prime(n: u64) -> bool {
    if n < 2 { return false; }
    if n == 2 { return true; }
    if n % 2 == 0 { return false; }
    
    let mut i = 3;
    while i * i <= n {
        if n % i == 0 { return false; }
        i += 2;
    }
    true
}

/// Get Monster group primes up to 71
pub fn monster_primes() -> Vec<u64> {
    let candidates = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71];
    candidates.iter()
        .filter(|&&p| is_prime(p))
        .copied()
        .collect()
}

/// Prime signature of a number
pub fn prime_signature(n: u64) -> Vec<u64> {
    monster_primes().into_iter()
        .filter(|&p| n % p == 0)
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_primes() {
        assert!(is_prime(2));
        assert!(is_prime(13));
        assert!(is_prime(71));
        assert!(!is_prime(4));
    }
    
    #[test]
    fn test_signature() {
        assert_eq!(prime_signature(6), vec![2, 3]);
        assert_eq!(prime_signature(30), vec![2, 3, 5]);
    }
}

fn main() {
    // Run multiple iterations to generate measurable heat
    for _ in 0..1000000 {
        let primes = monster_primes();
        assert_eq!(primes.len(), 20);
    }
    
    println!("Monster group primes: {:?}", monster_primes());
    
    // Test prime signatures
    for n in [6, 10, 30, 210] {
        let sig = prime_signature(n);
        println!("prime_signature({}) = {:?}", n, sig);
    }
}
