-- C syntax elements mapped to prime harmonics
import Mathlib.Data.Nat.Prime.Basic

structure CSyntax where
  name : String
  code : String
  prime : Nat
  harmonic : ℚ

def syntax_primes : List Nat := [2,3,5,7,11,13,17,19,23,29,31,41]

theorem all_syntax_primes_are_prime :
  ∀ p ∈ syntax_primes, Nat.Prime p := by
  intro p hp
  fin_cases hp <;> norm_num

def syntax_harmonic (p : Nat) : ℚ := 1 / p

theorem syntax_maps_to_proof :
  ∀ (s : CSyntax),
  Nat.Prime s.prime →
  s.harmonic = syntax_harmonic s.prime := by
  intro s hprime
  rfl

theorem program_complexity_is_sum :
  ∀ (elements : List CSyntax),
  (elements.map (·.prime)).sum =
  elements.foldl (fun acc s => acc + s.prime) 0 := by
  intro elements
  simp [List.sum]
