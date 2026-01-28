-- Scheme ∩ C convergence in prime lattice
import Mathlib.Data.Nat.Prime.Basic

inductive Language
| scheme : Language
| c : Language

def convergence_primes : List Nat := [2,3,5,7,11,13,17,19,23]

theorem all_convergence_primes_are_prime :
  ∀ p ∈ convergence_primes, Nat.Prime p := by
  intro p hp
  fin_cases hp <;> norm_num

axiom converges_at : Language → Language → Nat → Prop

theorem scheme_c_converge :
  ∀ p ∈ convergence_primes,
  converges_at Language.scheme Language.c p := by
  sorry

axiom compcert_implements : Nat → Prop

theorem convergence_implies_compcert :
  ∀ p ∈ convergence_primes,
  converges_at Language.scheme Language.c p →
  compcert_implements p := by
  sorry

def metacoq_level : Nat := 41

theorem metacoq_reflects_convergence :
  Nat.Prime metacoq_level ∧
  (∀ p ∈ convergence_primes, p < metacoq_level) := by
  constructor
  · norm_num
  · intro p hp
    fin_cases hp <;> norm_num
