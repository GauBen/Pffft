(** [premier n] renvoie [true] si [n] est premier, [false] sinon. *)
let premier n =
  let rec test diviseur saut =
    n mod diviseur <> 0
    && (diviseur * diviseur >= n || test (diviseur + saut) (6 - saut))
  in
  n > 1
  && (n = 2 || n = 3 || n = 5 || (n mod 2 <> 0 && n mod 3 <> 0 && test 5 2))

(* On peut instrumenter de la façon suivante le programme [premier], qui
   determine si un entier est premier, pour tester que pour tout entier non
   premier [a] entre 2 et 50, il existe b <> a tel que : a % b = 0. *)
let%test _ =
  let values =
    Flux.unfold (fun cpt -> if cpt <= 50 then Some (cpt, cpt + 1) else None) 2
  in
  Pffft.check
    Pffft.(
      fun () ->
        let a = forall values in
        let b = forsome values in
        assumption (fun () -> b < a);
        let r = premier a in
        assertion (fun () -> r || a mod b = 0))
