let prompt = Delimcc.new_prompt ()

(* On implémente la validité des exécutions avec deux exceptions : *)
exception Valid

exception Invalid

(* Déclarer une exécution valide correspond donc à l'interrompre avec une
   exception qui la déclare valide *)
let miracle () = raise Valid

let failure () = raise Invalid

let assumption predicate = if not (predicate ()) then miracle ()

let assertion predicate = if not (predicate ()) then failure ()

let forall_bool () =
  (* Évaluation paresseuse : on lance la deuxième continuation uniquement si la
     première exécution est valide *)
  Delimcc.shift prompt (fun cont -> try cont true with Valid -> cont false)

let forsome_bool () =
  (* Évaluation paresseuse : on lance la deuxième continuation uniquement si la
     première exécution est invalide *)
  Delimcc.shift prompt (fun cont -> try cont true with Invalid -> cont false)

let rec forall values =
  match Flux.uncons values with
  | Some (v, sequel) -> if forall_bool () then v else forall sequel
  (* Pour tout est vrai si [values] est vide *)
  | None -> miracle ()

let rec forsome values =
  match Flux.uncons values with
  | Some (v, sequel) -> if forsome_bool () then v else forsome sequel
  (* Il existe est faux si [values] est vide *)
  | None -> failure ()

let rec foratleast n values =
  (* Il existe au moins n est vrai pour n <= 0 *)
  if n <= 0 then miracle ();
  match Flux.uncons values with
  | Some (v, sequel) ->
      (* On forke deux fois, et selon l'exécution échouée, on sait si la
         première exécution fille est valide ou invalide *)
      let sucessful = forsome_bool () in
      if forall_bool () && sucessful then v
      else foratleast (if sucessful then n - 1 else n) sequel
  (* Il existe au moins n est faux si [values] est vide *)
  | None -> failure ()

let check f =
  (* On ignore le résultat pour laisser prompt non typé *)
  try () = ignore (Delimcc.push_prompt prompt (fun () -> miracle (f ()))) with
  (* L'exception propagée jusqu'au bout donne la validité de l'exécution *)
  | Valid -> true
  | Invalid -> false

let on_success f =
  (* On ajoute f dans la pile avant de propager l'exception *)
  Delimcc.shift prompt (fun cont -> try cont () with Valid -> miracle (f ()))

let on_failure f =
  Delimcc.shift prompt (fun cont ->
      try cont () with Invalid -> failure (f ()))

let forall_length lengths values =
  List.init (forall lengths) (fun _ -> values ())

let forsome_length lengths values =
  List.init (forsome lengths) (fun _ -> values ())

let foratleast_length n lengths values =
  List.init (foratleast n lengths) (fun _ -> values ())
