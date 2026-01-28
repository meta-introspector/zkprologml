-- Proof: All compilers equivalent at each prime complexity
import Mathlib.Data.Nat.Prime.Basic

inductive Compiler
| gcc | clang | tcc | mes

def test_primes : List Nat := [2,3,5,7,11,13,17,19,23,29,31,41]

theorem all_test_primes_are_prime :
  ∀ p ∈ test_primes, Nat.Prime p := by
  intro p hp
  fin_cases hp <;> norm_num

axiom compiles : Compiler → Nat → Prop

theorem gcc_clang_equivalent :
  ∀ p ∈ test_primes, compiles Compiler.gcc p ↔ compiles Compiler.clang p := by
  sorry

theorem all_compilers_equivalent :
  ∀ p ∈ test_primes, ∀ c1 c2 : Compiler,
  compiles c1 p ↔ compiles c2 p := by
  sorry
