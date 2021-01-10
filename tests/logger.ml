(* Le prédicat de base à tester *)
let pred x y z = x = (5 * y) + (7 * z)

(* On teste sur les entiers pairs de 10 à 50 *)
let%test _ =
  let interval a b =
    Flux.unfold (fun cpt -> if cpt > b then None else Some (cpt, cpt + 1)) a
  in
  not
    (Pffft.check
       Pffft.(
         fun () ->
           (* affiche la validité (ou non) de la propriété Q *)
           on_success (fun () -> Format.printf "Q est valide@.");
           on_failure (fun () -> Format.printf "Q est invalide@.");
           let x = forall (interval 10 50) in
           on_failure (fun () -> Format.printf "non P(%d)@." x);
           assumption (fun () -> x mod 2 = 0);
           let y = forsome (interval 0 20) in
           let z = forsome (interval 0 20) in
           on_success (fun () -> Format.printf "%d = 5 * %d + 7 * %d@." x y z);
           assertion (fun () -> pred x y z)))
