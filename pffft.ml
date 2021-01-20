let prompt = Delimcc.new_prompt ()

(* On représente une exécution valide par true, invalide par false *)
let miracle () = Delimcc.shift prompt (fun _ -> true)

let failure () = Delimcc.shift prompt (fun _ -> false)

let assumption predicate = if not (predicate ()) then miracle ()

let assertion predicate = if not (predicate ()) then failure ()

(* L'exécution est valide si et seulement si les deux exécutions filles le sont *)
let forall_bool () = Delimcc.shift prompt (fun cont -> cont true && cont false)

(* ... si au moins une exécution fille est valide *)
let forsome_bool () = Delimcc.shift prompt (fun cont -> cont true || cont false)

let rec forall values =
  match Flux.uncons values with
  | Some (v, sequel) -> if forall_bool () then v else forall sequel
  (* "Pour tout" est vrai si [values] est vide *)
  | None -> miracle ()

let rec forsome values =
  match Flux.uncons values with
  | Some (v, sequel) -> if forsome_bool () then v else forsome sequel
  (* "Il existe" est faux si [values] est vide *)
  | None -> failure ()

let rec foratleast n values =
  (* "Il existe au moins n" est vrai pour n <= 0 *)
  if n <= 0 then miracle ();
  match Flux.uncons values with
  | Some (v, sequel) ->
      (* On forke deux fois, et selon la valeur de [successful], on sait si la
         première exécution fille est valide ou invalide *)
      let sucessful = forsome_bool () in
      if forall_bool () && sucessful then v
      else foratleast (if sucessful then n - 1 else n) sequel
  (* "Il existe au moins n" est faux si [values] est vide *)
  | None -> failure ()

(* [f () = ()] <=> [f (); true] mais évite 3 retours à la ligne de ocamlformat
   On renvoie [true] quand l'exécution se termine car toute exécution qui se
   termine est considérée valide *)
let check f = Delimcc.push_prompt prompt (fun () -> f () = ())

(* On ajoute f dans la pile avant de faire remonter le résultat *)
let on_success f = Delimcc.shift prompt (fun cont -> cont () && f () = ())

let on_failure f = Delimcc.shift prompt (fun cont -> cont () || f () <> ())

let forall_length lengths values =
  List.init (forall lengths) (fun _ -> values ())

let forsome_length lengths values =
  List.init (forsome lengths) (fun _ -> values ())

let foratleast_length n lengths values =
  List.init (foratleast n lengths) (fun _ -> values ())
