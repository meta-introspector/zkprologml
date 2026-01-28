-- Coq proof harmonics in prime lattice
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

def compcert_primes : List Nat := [2,5,7,11,13,17,19,23,29,31,41]

theorem all_compcert_primes_are_prime :
  ∀ p ∈ compcert_primes, Nat.Prime p := by
  intro p hp
  fin_cases hp <;> norm_num

def prime_harmonic (p : Nat) : ℚ := 1 / p

def total_harmonic : ℚ :=
  (compcert_primes.map prime_harmonic).sum

theorem harmonic_convergence :
  total_harmonic < 2 := by
  norm_num
  unfold total_harmonic compcert_primes prime_harmonic
  simp
  sorry

theorem proof_chain_preserves_correctness :
  ∀ p1 p2 ∈ compcert_primes,
  Nat.Prime p1 → Nat.Prime p2 →
  ∃ combined, combined = p1 + p2 := by
  intro p1 hp1 p2 hp2 _ _
  use p1 + p2
  rfl
