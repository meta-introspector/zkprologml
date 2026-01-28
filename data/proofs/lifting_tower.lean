-- Lifting tower: C → CompCert → Coq → MetaCoq
import Mathlib.Data.Nat.Prime.Basic

inductive LiftLevel
| c_syntax : LiftLevel
| compcert_ir : LiftLevel
| coq_proof : LiftLevel
| metacoq_term : LiftLevel
| metacoq_type : LiftLevel
| universe : LiftLevel

def level_complexity : LiftLevel → Nat
| .c_syntax => 2
| .compcert_ir => 5
| .coq_proof => 11
| .metacoq_term => 23
| .metacoq_type => 41
| .universe => 71

theorem all_levels_prime :
  ∀ l : LiftLevel, Nat.Prime (level_complexity l) := by
  intro l
  cases l <;> norm_num

def total_complexity : Nat :=
  2 + 5 + 11 + 23 + 41 + 71

theorem total_is_153 : total_complexity = 153 := by rfl

axiom lift : (l1 l2 : LiftLevel) → Prop

theorem lifting_preserves_correctness :
  lift .c_syntax .compcert_ir →
  lift .compcert_ir .coq_proof →
  lift .coq_proof .metacoq_term →
  lift .metacoq_term .metacoq_type →
  lift .metacoq_type .universe →
  lift .c_syntax .universe := by
  sorry
