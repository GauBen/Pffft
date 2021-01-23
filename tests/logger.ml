(* Le prédicat de base à tester *)
let pred x y z = x = (5 * y) + (7 * z)

(* On teste sur les entiers pairs de 10 à 50 *)
let%test _ =
  let interval a b =
    Flux.unfold (fun cpt -> if cpt > b then None else Some (cpt, cpt + 1)) a
  in
  let output = ref [] in
  (not
     (Pffft.check
        Pffft.(
          fun () ->
            (* affiche la validité (ou non) de la propriété Q *)
            on_success (fun () ->
                output := Format.sprintf "Q est valide@." :: !output);
            on_failure (fun () ->
                output := Format.sprintf "Q est invalide@." :: !output);
            let x = forall (interval 10 50) in
            on_failure (fun () ->
                output := Format.sprintf "non P(%d)@." x :: !output);
            assumption (fun () -> x mod 2 = 0);
            let y = forsome (interval 0 20) in
            let z = forsome (interval 0 20) in
            on_success (fun () ->
                output :=
                  Format.sprintf "%d = 5 * %d + 7 * %d@." x y z :: !output);
            assertion (fun () -> pred x y z))))
  && !output
     = [
         "non P(16)\n";
         "14 = 5 * 0 + 7 * 2\n";
         "12 = 5 * 1 + 7 * 1\n";
         "10 = 5 * 2 + 7 * 0\n";
         "Q est invalide\n";
       ]

let%test _ =
  let l = ref [] in
  let _ =
    Pffft.check
      Pffft.(
        fun () ->
          on_success (fun () -> l := 0 :: !l);
          on_success (fun () -> l := 1 :: !l);
          on_failure (fun () -> l := 2 :: !l);
          on_success (fun () -> l := 3 :: !l))
  in
  !l = [ 3; 1; 0 ]

let%test _ =
  let l = ref [] in
  let _ =
    Pffft.check
      Pffft.(
        fun () ->
          on_success (fun () -> l := 0 :: !l);
          let _ = forall_bool () in
          on_success (fun () -> l := 1 :: !l);
          let b = forsome_bool () in
          on_failure (fun () -> l := 2 :: !l);
          on_success (fun () -> l := 3 :: !l);
          assertion (fun () -> not b))
  in
  !l = [ 3; 2; 1; 3; 2; 1; 0 ]

let%test _ =
  let l = ref [] in
  let _ =
    Pffft.check
      Pffft.(
        fun () ->
          on_failure (fun () -> l := 0 :: !l);
          let _ = forsome_bool () in
          on_failure (fun () -> l := 1 :: !l);
          let b = forall_bool () in
          on_failure (fun () -> l := 2 :: !l);
          on_success (fun () -> l := 3 :: !l);
          assertion (fun () -> b))
  in
  !l = [ 2; 3; 1; 2; 3; 1; 0 ]
