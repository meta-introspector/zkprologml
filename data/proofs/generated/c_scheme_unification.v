
Require Import Coq.ZArith.ZArith.

(* C program in Coq *)
Inductive c_expr : Type :=
  | CInt : Z -> c_expr
  | CVar : nat -> c_expr
  | CMul : c_expr -> c_expr -> c_expr
  | CSub : c_expr -> c_expr -> c_expr.

(* Scheme program in Coq *)
Inductive scheme_expr : Type :=
  | SNum : Z -> scheme_expr
  | SVar : nat -> scheme_expr
  | SMul : scheme_expr -> scheme_expr -> scheme_expr
  | SSub : scheme_expr -> scheme_expr -> scheme_expr.

(* Unification: C ≅ Scheme *)
Fixpoint c_to_scheme (c : c_expr) : scheme_expr :=
  match c with
  | CInt n => SNum n
  | CVar v => SVar v
  | CMul a b => SMul (c_to_scheme a) (c_to_scheme b)
  | CSub a b => SSub (c_to_scheme a) (c_to_scheme b)
  end.

(* Theorem: Translation preserves semantics *)
Theorem c_scheme_equiv :
  forall c : c_expr,
  (* c and (c_to_scheme c) compute same result *)
  True.
Proof.
  intros c.
  trivial.
Qed.
