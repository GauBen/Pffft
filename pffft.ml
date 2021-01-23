(* On représente une exécution valide par true, invalide par false, et on y
   ajoute la liste des callbacks *)
type result = bool * (unit -> unit) list

let prompt : result Delimcc.prompt = Delimcc.new_prompt ()

let miracle () = Delimcc.shift prompt (fun _ -> (true, []))

let failure () = Delimcc.shift prompt (fun _ -> (false, []))

let assumption predicate = if not (predicate ()) then miracle ()

let assertion predicate = if not (predicate ()) then failure ()

(* Forke en 1 ou 2 exécutions, selon le resultat de la première *)
let fork_bool b =
  Delimcc.shift prompt (fun cont ->
      let r1, l1 = cont true in
      if r1 = b then (r1, l1)
      else
        let r2, l2 = cont false in
        (r2, l1 @ l2))

(* L'exécution est valide si et seulement si les deux exécutions filles le sont *)
let forall_bool () = fork_bool false

(* ... si au moins une exécution fille est valide *)
let forsome_bool () = fork_bool true

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
  match (n, Flux.uncons values) with
  | n, Some (v, sequel) when n > 0 ->
      (* On forke deux fois, et selon la valeur de [successful], on sait si la
         première exécution fille est valide ou invalide *)
      let sucessful = forsome_bool () in
      if forall_bool () && sucessful then v
      else foratleast (if sucessful then n - 1 else n) sequel
  (* "Il existe au moins n" est faux si [values] est vide *)
  | n, None when n > 0 -> failure ()
  (* "Il existe au moins n" est vrai pour n <= 0 *)
  | _ -> miracle ()

(* [f () = ()] <=> [f (); true] mais évite 3 retours à la ligne de ocamlformat
   On renvoie [true] quand l'exécution se termine car toute exécution qui se
   termine est considérée valide *)
let check f =
  let r, l = Delimcc.push_prompt prompt (fun () -> (f () = (), [])) in
  List.iter (fun f -> f ()) l;
  r

(* On ajoute f dans la pile avant de faire remonter le résultat *)
let log b f =
  Delimcc.shift prompt (fun cont ->
      let r, l = cont () in
      if r = b then (r, f :: l) else (r, l))

let on_success f = log true f

let on_failure f = log false f

let forall_length lengths values =
  List.init (forall lengths) (fun _ -> values ())

let forsome_length lengths values =
  List.init (forsome lengths) (fun _ -> values ())

let foratleast_length n lengths values =
  List.init (foratleast n lengths) (fun _ -> values ())
