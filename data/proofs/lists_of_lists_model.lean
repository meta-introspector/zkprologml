-- Lists of Lists Complexity Lattice Model

structure ListsOfListsModel where
  structure : String
  complexity : Nat
  monotonic : Bool
  automorphic : Bool
  galois_invariant : Bool

def lists_of_lists_model : ListsOfListsModel := {
  structure := "lists_of_lists",
  complexity := 23,
  monotonic := true,
  automorphic := true,
  galois_invariant := true
}

theorem lists_of_lists_proven : 
  lists_of_lists_model.complexity = 23 := by
  rfl
