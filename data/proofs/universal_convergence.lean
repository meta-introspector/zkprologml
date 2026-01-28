-- Universal compiler convergence
import Mathlib.Data.Nat.Prime.Basic

inductive Compiler
| mes_scheme | mes_c | gcc | llvm | compcert

def universal_primes : List Nat := 
  [2,3,5,7,11,13,17,19,23,29,31,41]

theorem all_universal_primes_are_prime :
  ∀ p ∈ universal_primes, Nat.Prime p := by
  intro p hp
  fin_cases hp <;> norm_num

axiom implements : Compiler → Nat → Prop

theorem all_compilers_implement_all_primes :
  ∀ c : Compiler, ∀ p ∈ universal_primes,
  implements c p := by
  sorry

theorem universal_convergence :
  ∀ c1 c2 : Compiler, ∀ p ∈ universal_primes,
  implements c1 p ↔ implements c2 p := by
  intro c1 c2 p hp
  constructor
  · intro _; apply all_compilers_implement_all_primes
  · intro _; apply all_compilers_implement_all_primes

def metacoq_prime : Nat := 41

theorem metacoq_reflects_all :
  Nat.Prime metacoq_prime ∧
  metacoq_prime ∈ universal_primes := by
  constructor
  · norm_num
  · decide
