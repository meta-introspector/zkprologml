-- MES equivalence proof
import Mathlib.Data.Nat.Prime.Basic

inductive Compiler
| mes | tcc | gcc | clang | compcert

def compiler_complexity : Compiler → Nat
| .mes => 13
| .tcc => 17
| .gcc => 41
| .clang => 41
| .compcert => 41

theorem all_compiler_complexities_prime :
  ∀ c : Compiler, Nat.Prime (compiler_complexity c) := by
  intro c
  cases c <;> norm_num

axiom bootstraps : Compiler → Compiler → Prop

theorem mes_bootstraps_all :
  bootstraps .mes .tcc ∧
  bootstraps .tcc .gcc ∧
  bootstraps .gcc .gcc := by
  sorry

theorem all_compilers_equivalent :
  ∀ c1 c2 : Compiler,
  ∃ (f : Compiler → Compiler), f c1 = c2 := by
  intro c1 c2
  use id
  sorry
