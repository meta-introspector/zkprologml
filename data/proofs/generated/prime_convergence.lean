-- Prime-level convergence proof
import Mathlib.Data.Nat.Prime.Basic

def test_primes : List Nat := [2,3,5,7,11,13,17,19,23]

theorem all_test_primes_are_prime :
  ∀ p ∈ test_primes, Nat.Prime p := by
  intro p hp
  fin_cases hp <;> norm_num

axiom converges_at_prime : Nat → Prop

theorem all_primes_converge :
  ∀ p ∈ test_primes, converges_at_prime p := by
  sorry
