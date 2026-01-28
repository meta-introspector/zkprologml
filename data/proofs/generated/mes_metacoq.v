Require Import Coq.ZArith.ZArith.
Require Import compcert.lib.Integers.
Require Import compcert.common.AST.
Require Import compcert.cfrontend.Clight.

(* MES C program in Clight *)
(* Load /tmp/nix-shell.j2v3am/swipl_1110922_2.v *)

(* Correctness theorem *)
Theorem mes_c_correct :
  forall ge e le m,
  (* MES C program preserves prime lattice structure *)
  True.  (* TODO: formalize *)
Proof.
  intros.
  trivial.
Qed.

(* Scheme as dependent type of C *)
Definition SchemeType (c_prog : Clight.program) : Type :=
  { scheme_prog : nat | 
    (* Scheme program is a proof about C program *)
    prime_signature scheme_prog = prime_signature (hash c_prog) }.


Require Import MetaCoq.Template.All.

Run TemplateProgram (tmQuoteRec mes_c_correct >>= tmDefinition "mes_proof_quoted").
