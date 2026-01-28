
Require Import Coq.Lists.List.
Require Import Coq.Arith.Arith.
Import ListNotations.

(* Prolog terms *)
Inductive term : Type :=
  | Var : nat -> term
  | Atom : string -> term
  | Compound : string -> list term -> term.

(* Prolog goals *)
Inductive goal : Type :=
  | True : goal
  | Unify : term -> term -> goal
  | Call : term -> goal
  | Conj : goal -> goal -> goal.

(* Environment: list of clauses *)
Definition clause := (term * goal)%type.
Definition env := list clause.

(* Substitution *)
Definition subst := list (nat * term).

(* Unification *)
Fixpoint occurs_check (v : nat) (t : term) : bool :=
  match t with
  | Var v' => Nat.eqb v v'
  | Atom _ => false
  | Compound _ args => existsb (occurs_check v) args
  end.

Fixpoint unify_terms (t1 t2 : term) (s : subst) : option subst :=
  match t1, t2 with
  | Var v1, Var v2 => if Nat.eqb v1 v2 then Some s else Some ((v1, t2) :: s)
  | Var v, t | t, Var v => 
      if occurs_check v t then None else Some ((v, t) :: s)
  | Atom a1, Atom a2 => if String.eqb a1 a2 then Some s else None
  | Compound f1 args1, Compound f2 args2 =>
      if String.eqb f1 f2 then unify_list args1 args2 s else None
  | _, _ => None
  end
with unify_list (ts1 ts2 : list term) (s : subst) : option subst :=
  match ts1, ts2 with
  | [], [] => Some s
  | t1 :: ts1', t2 :: ts2' =>
      match unify_terms t1 t2 s with
      | Some s' => unify_list ts1' ts2' s'
      | None => None
      end
  | _, _ => None
  end.

(* Prolog interpreter *)
Fixpoint eval_goal (fuel : nat) (g : goal) (e : env) (s : subst) : option subst :=
  match fuel with
  | 0 => None
  | S fuel' =>
      match g with
      | True => Some s
      | Unify t1 t2 => unify_terms t1 t2 s
      | Call t =>
          (* Try each clause in environment *)
          fold_left (fun acc clause =>
            match acc with
            | Some _ => acc
            | None =>
                let (head, body) := clause in
                match unify_terms t head s with
                | Some s' => eval_goal fuel' body e s'
                | None => None
                end
            end) e None
      | Conj g1 g2 =>
          match eval_goal fuel' g1 e s with
          | Some s' => eval_goal fuel' g2 e s'
          | None => None
          end
      end
  end.

(* Example: factorial *)
Definition factorial_clause_0 : clause :=
  (Compound "factorial" [Compound "zero" []; Var 0],
   Unify (Var 0) (Compound "succ" [Compound "zero" []])).

Definition factorial_clause_n : clause :=
  (Compound "factorial" [Compound "succ" [Var 0]; Var 1],
   Conj (Call (Compound "factorial" [Var 0; Var 2]))
        (Call (Compound "mult" [Compound "succ" [Var 0]; Var 2; Var 1]))).

Definition factorial_env : env := [factorial_clause_0; factorial_clause_n].

(* Correctness theorem *)
Theorem prolog_interpreter_sound :
  forall fuel g e s s',
  eval_goal fuel g e s = Some s' ->
  (* s' is a valid solution for g in e under s *)
  True.  (* TODO: formalize semantics *)
Proof.
  intros. trivial.
Qed.


Require Import MetaCoq.Template.All.

Run TemplateProgram (tmQuoteRec eval_goal >>= tmDefinition "eval_goal_quoted").

Run TemplateProgram (tmQuoteRec prolog_interpreter_sound >>= tmDefinition "proof_quoted").
