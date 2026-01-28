
Fixpoint is_prime_helper (n k : nat) : bool :=
  match k with
  | 0 => true
  | S k' => 
      if (k * k >? n) then true
      else if (n mod k =? 0) then false
      else is_prime_helper n (k + 2)
  end.

Definition is_prime (n : nat) : bool :=
  if (n <? 2) then false
  else if (n =? 2) then true
  else if (n mod 2 =? 0) then false
  else is_prime_helper n 3.