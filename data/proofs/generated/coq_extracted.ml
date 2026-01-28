
(* Extracted from Coq *)

let rec is_prime_helper n k =
  if k * k > n then true
  else if n mod k = 0 then false
  else is_prime_helper n (k + 2)

let is_prime n =
  if n < 2 then false
  else if n = 2 then true
  else if n mod 2 = 0 then false
  else is_prime_helper n 3

let monster_primes = [2; 3; 5; 7; 11; 13; 17; 19; 23; 29; 31; 37; 41; 43; 47; 53; 59; 61; 67; 71]

let prime_signature n =
  List.filter (fun p -> n mod p = 0) monster_primes

let () =
  Printf.printf "Monster primes: ";
  List.iter (Printf.printf "%d ") monster_primes;
  Printf.printf "\n";
  
  List.iter (fun n ->
    let sig_list = prime_signature n in
    Printf.printf "prime_signature(%d) = [" n;
    List.iter (Printf.printf "%d ") sig_list;
    Printf.printf "]\n"
  ) [6; 10; 30; 210]
