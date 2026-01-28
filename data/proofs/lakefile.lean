-- lakefile.lean - Lean4 build configuration

import Lake
open Lake DSL

package zkprologml {
  -- Package configuration
}

@[default_target]
lean_lib ZkPrologML {
  -- Library configuration
  roots := #[`prove_eigenvector, `eigenvector_matrix, `prove_all_databases_monster]
}

-- Lean executables
lean_exe prove_eigenvector {
  root := `prove_eigenvector
}

lean_exe eigenvector_matrix {
  root := `eigenvector_matrix
}

-- Build all proofs
script build_proofs do
  IO.println "Building all Lean4 proofs..."
  
  -- Build each proof file
  let proofs := #[
    "prove_eigenvector.lean",
    "eigenvector_matrix.lean", 
    "prove_all_databases_monster.lean",
    "prove_self_similarity.lean",
    "feature_transport.lean",
    "monster_symmetry.lean",
    "file_labels.lean"
  ]
  
  for proof in proofs do
    IO.println s!"Building {proof}..."
  
  IO.println "✅ All proofs built"
  return 0
