
Require Import Coq.Arith.Arith.

(* All factorial implementations *)
Fixpoint factorial_rust (n : nat) : nat :=
  match n with
  | 0 => 1
  | S n' => n * factorial_rust n'
  end.

Fixpoint factorial_ocaml (n : nat) : nat :=
  match n with
  | 0 => 1
  | S n' => n * factorial_ocaml n'
  end.

Fixpoint factorial_c (n : nat) : nat :=
  match n with
  | 0 => 1
  | S n' => n * factorial_c n'
  end.

Fixpoint factorial_prolog (n : nat) : nat :=
  match n with
  | 0 => 1
  | S n' => n * factorial_prolog n'
  end.

(* Unification theorem *)
Theorem all_factorials_equivalent :
  forall n,
  factorial_rust n = factorial_ocaml n /\
  factorial_ocaml n = factorial_c n /\
  factorial_c n = factorial_prolog n.
Proof.
  intros n.
  split. 2: split.
  - (* rust = ocaml *) induction n; simpl; auto. rewrite IHn. reflexivity.
  - (* ocaml = c *) induction n; simpl; auto. rewrite IHn. reflexivity.
  - (* c = prolog *) induction n; simpl; auto. rewrite IHn. reflexivity.
Qed.

(* Corollary: All are equal *)
Corollary universal_factorial_equivalence :
  forall n,
  factorial_rust n = factorial_ocaml n /\
  factorial_rust n = factorial_c n /\
  factorial_rust n = factorial_prolog n.
Proof.
  intros n.
  pose proof (all_factorials_equivalent n) as H.
  destruct H as [H1 [H2 H3]].
  split. exact H1.
  split. rewrite H1. exact H2.
  rewrite H1, H2. exact H3.
Qed.

(* The 1980s dream: Verified unification! *)
Print universal_factorial_equivalence.
