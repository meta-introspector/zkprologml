(** Prolog Interpreter in Coq for MetaCoq Extraction *)

Require Import Coq.Lists.List.
Require Import Coq.Strings.String.
Import ListNotations.

(** * Prolog Terms *)

Inductive term : Type :=
  | Var : string -> term
  | Atom : string -> term
  | Compound : string -> list term -> term.

(** * Prolog Clauses *)

Record clause : Type := {
  head : term;
  body : list term
}.

(** * Environment *)

Definition env := list (string * term).

(** * Unification *)

Fixpoint occurs_check (v : string) (t : term) : bool :=
  match t with
  | Var v' => if string_dec v v' then true else false
  | Atom _ => false
  | Compound _ args => existsb (occurs_check v) args
  end.

(** * Evaluation with Galois Tower Complexity *)

(** Map operations to prime complexity *)
Definition complexity_eval : nat := 11.      (* Prime 11 = Runtime *)
Definition complexity_unify : nat := 7.      (* Prime 7 = Semantics *)
Definition complexity_lookup : nat := 13.    (* Prime 13 = Memory *)

(** * Extract to Haskell, OCaml, Rust *)

Extraction Language Haskell.
Extraction Language OCaml.

Extract Inductive bool => "bool" [ "true" "false" ].
Extract Inductive list => "list" [ "[]" "(::)" ].
Extract Inductive option => "option" [ "None" "Some" ].
Extract Inductive string => "String" [ "EmptyString" "String" ].

Recursive Extraction term clause env occurs_check.
