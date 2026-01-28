(* AUTO-GENERATED: Universal convergence proof *)
Theorem universal_convergence :
  forall p, Prime p -> converges_at p.
Proof. intros. apply convergence_lemma. Qed.
