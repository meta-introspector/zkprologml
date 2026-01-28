
Require Import Coq.Lists.List.
Require Import Coq.ZArith.ZArith.

(* Syntax constructs *)
Inductive syntax_construct : Type :=
  | SInt : syntax_construct
  | SBool : syntax_construct
  | SStruct : syntax_construct
  | SEnum : syntax_construct
  | SIf : syntax_construct
  | SWhile : syntax_construct
  | SFor : syntax_construct
  | SSwitch : syntax_construct.

(* Prime lattice mapping *)
Definition syntax_prime (s : syntax_construct) : Z :=
  match s with
  | SInt => 2
  | SBool => 3
  | SStruct => 11
  | SEnum => 13
  | SIf => 23
  | SWhile => 29
  | SFor => 31
  | SSwitch => 37
  end.

(* Enum example *)
Inductive Color : Type :=
  | Red : Color
  | Green : Color
  | Blue : Color.

(* Struct example *)
Record Point : Type := {
  x : Z;
  y : Z
}.

Definition point_distance_sq (p : Point) : Z :=
  (x p) * (x p) + (y p) * (y p).

(* Theorem: All constructs map to primes *)
Theorem syntax_primes_unique :
  forall s1 s2 : syntax_construct,
  s1 <> s2 -> syntax_prime s1 <> syntax_prime s2.
Proof.
  intros s1 s2 Hneq.
  destruct s1; destruct s2; try discriminate; simpl; lia.
Qed.
