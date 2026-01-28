-- GCC tree.h mapping to prime lattice
import Mathlib.Data.Nat.Prime.Basic

inductive TreeCode
| INTEGER_TYPE | PLUS_EXPR | VAR_DECL | COND_EXPR
| FUNCTION_DECL | POINTER_TYPE | RECORD_TYPE | ARRAY_TYPE
| MEM_REF | SSA_NAME | STATEMENT_LIST | ASM_EXPR

def tree_complexity : TreeCode → Nat
| .INTEGER_TYPE => 2
| .PLUS_EXPR => 3
| .VAR_DECL => 5
| .COND_EXPR => 7
| .FUNCTION_DECL => 11
| .POINTER_TYPE => 13
| .RECORD_TYPE => 17
| .ARRAY_TYPE => 19
| .MEM_REF => 23
| .SSA_NAME => 29
| .STATEMENT_LIST => 31
| .ASM_EXPR => 41

theorem all_tree_complexities_prime :
  ∀ t : TreeCode, Nat.Prime (tree_complexity t) := by
  intro t
  cases t <;> norm_num

axiom maps_to_compcert : TreeCode → Prop

theorem tree_maps_to_compcert :
  ∀ t : TreeCode, maps_to_compcert t := by
  sorry
