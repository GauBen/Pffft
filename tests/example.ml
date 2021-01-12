(** Produit un flux d'entiers de l'intervale [a; b] contenant ses bornes. *)
let range a b =
  Flux.unfold (fun x -> if x <= b then Some (x, x + 1) else None) a

(* Utilisation de Pffft sur le théorème : *)
let _ =
  if
    Pffft.check
      Pffft.(
        fun () ->
          (* Pour tout entier n dans [3; 99] :*)
          let n = forall (range 3 99) in
          (* tel que n impair : *)
          assumption (fun () -> n mod 2 = 1);
          on_success (fun () -> Format.printf "%d est premier.@." n);
          (* Pour tout entier p dans [2; n-1] :*)
          let p = forall (range 2 (n - 1)) in
          on_failure (fun () ->
              Format.printf "Contre-exemple : %d divise %d.@." p n);
          (* p ne divise pas n : *)
          assertion (fun () -> n mod p <> 0))
  then failwith "Le théorème est juste jusqu'à 99."
  else print_endline "Le théorème est faux."
