-- AUTO-GENERATED: Universal convergence proof
theorem universal_convergence :
  ∀ p, Nat.Prime p → converges_at p := by
  intro p hp
  apply convergence_lemma
