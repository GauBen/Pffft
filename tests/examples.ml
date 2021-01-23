(** Produit un flux d'entiers de l'intervale [a; b] contenant ses bornes. *)
let range a b =
  Flux.unfold (fun x -> if x <= b then Some (x, x + 1) else None) a

(* Utilisation de Pffft sur le théorème : *)
let%test _ =
  let output = ref [] in
  (not
     (Pffft.check
        Pffft.(
          fun () ->
            (* Pour tout entier n dans [3; 99] : *)
            let n = forall (range 3 99) in
            (* tel que n impair : *)
            assumption (fun () -> n mod 2 = 1);
            on_success (fun () ->
                output := Format.sprintf "%d est premier.@." n :: !output);
            (* Pour tout entier p dans [2; n-1] : *)
            let p = forall (range 2 (n - 1)) in
            on_failure (fun () ->
                output :=
                  Format.sprintf "Contre-exemple : %d divise %d.@." p n
                  :: !output);
            (* p ne divise pas n : *)
            assertion (fun () -> n mod p <> 0))))
  && !output
     = [
         "Contre-exemple : 3 divise 9.\n";
         "7 est premier.\n";
         "5 est premier.\n";
         "3 est premier.\n";
       ]

let%test _ =
  let is_lower c = c = Char.lowercase_ascii c in
  not
    (Pffft.check
       Pffft.(
         fun () ->
           let c = forall (Flux.of_list [ 'h'; 'e'; 'y'; 'H'; 'i' ]) in
           assertion (fun () -> is_lower c)))

let%test _ =
  let is_lower c = c = Char.lowercase_ascii c in
  Pffft.check
    Pffft.(
      fun () ->
        let c = forsome (Flux.of_list [ 'H'; 'E'; 'Y'; 'h'; 'I' ]) in
        assertion (fun () -> is_lower c))

let%test _ =
  let is_prime n =
    let rec aux n i =
      if i * i > n then true else n mod i <> 0 && aux n (i + 1)
    in
    n >= 2 && aux n 2
  in
  Pffft.check
    Pffft.(
      fun () ->
        let a = forall (range 2 20) in
        if is_prime a then
          let b = foratleast (a - 2) (range 1 a) in
          assertion (fun () -> a mod b <> 0)
        else
          let b = foratleast 3 (range 1 a) in
          assertion (fun () -> a mod b = 0))

let%test _ =
  let is_prime n =
    let rec aux n i =
      if i * i > n then true else n mod i <> 0 && aux n (i + 1)
    in
    n >= 2 && aux n 2
  in
  let output = ref [] in
  Pffft.check
    Pffft.(
      fun () ->
        let a = forall (range 2 6) in
        if is_prime a then (
          on_success (fun () ->
              output :=
                Format.sprintf "%d est premier et n'a que 2 diviseurs.@." a
                :: !output);
          let b = foratleast (a - 2) (range 1 a) in
          assertion (fun () -> a mod b <> 0))
        else (
          on_success (fun () ->
              output :=
                Format.sprintf
                  "%d n'est pas premier et a au moins 3 diviseurs.@." a
                :: !output);
          let b = foratleast 3 (range 1 a) in
          assertion (fun () -> a mod b = 0)))
  && !output
     = [
         "6 n'est pas premier et a au moins 3 diviseurs.\n";
         "5 est premier et n'a que 2 diviseurs.\n";
         "4 n'est pas premier et a au moins 3 diviseurs.\n";
         "3 est premier et n'a que 2 diviseurs.\n";
         "2 est premier et n'a que 2 diviseurs.\n";
       ]

let is_subset subset set =
  Pffft.check
    Pffft.(
      fun () ->
        let x = forall (Flux.of_list subset) in
        let y = forsome (Flux.of_list set) in
        assertion (fun () -> x = y))

let%test _ = is_subset [ 'a'; 'b' ] [ 'a'; 'b'; 'c' ]

let%test _ = is_subset [ 'a'; 'b' ] [ 'a'; 'b' ]

let%test _ = not (is_subset [ 'a'; 'b' ] [ 'a' ])

let%test _ = not (is_subset [ 'a' ] [])

let%test _ = not (is_subset [ 'b' ] [ 'a' ])

let%test _ = is_subset [ 'a' ] [ 'a' ]

let%test _ = is_subset [] [ 'a' ]

let%test _ = is_subset [] []

let%test _ =
  let is_prime_pffft n =
    n >= 2
    && not
         (Pffft.check
            Pffft.(
              fun () ->
                let i = forsome (range 2 (n / 2)) in
                assertion (fun () -> n mod i = 0)))
  in
  let is_prime_pffft2 n =
    n >= 2
    && Pffft.check
         Pffft.(
           fun () ->
             let i = forall (range 2 (n / 2)) in
             assertion (fun () -> n mod i <> 0))
  in
  let is_prime n =
    let rec aux n i =
      if i * i > n then true else n mod i <> 0 && aux n (i + 1)
    in
    n >= 2 && aux n 2
  in
  Pffft.check
    Pffft.(
      fun () ->
        let n = forall (range 0 50) in
        let prime = is_prime n in
        assertion (fun () ->
            is_prime_pffft n = prime && is_prime_pffft2 n = prime))
