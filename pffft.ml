let pt = Delimcc.new_prompt ()

exception Valid

exception Invalid

let miracle () = raise Valid

let failure () = raise Invalid

let assumption predicate = if not (predicate ()) then miracle ()

let assertion predicate = if not (predicate ()) then failure ()

let forall_bool () =
  Delimcc.shift pt (fun cont -> try cont true with Valid -> cont false)

let forsome_bool () =
  Delimcc.shift pt (fun cont -> try cont true with Invalid -> cont false)

let rec forall values =
  match Flux.uncons values with
  | Some (v, sequel) -> if forall_bool () then v else forall sequel
  | None -> miracle ()

let rec forsome values =
  match Flux.uncons values with
  | Some (v, sequel) -> if forsome_bool () then v else forsome sequel
  | None -> failure ()

let rec foratleast n values =
  if n <= 0 then miracle ();
  match Flux.uncons values with
  | Some (v, sequel) -> (
      match
        Delimcc.shift pt (fun cont ->
            try cont None with
            | Valid -> cont (Some (n - 1))
            | Invalid -> cont (Some n))
      with
      | None -> v
      | Some n -> foratleast n sequel)
  | None -> failure ()

let check f =
  try
    let _ =
      Delimcc.push_prompt pt (fun () ->
          f ();
          miracle ())
    in
    true
  with
  | Valid -> true
  | _ -> false

let on_success f =
  Delimcc.shift pt (fun cont ->
      try cont ()
      with Valid ->
        f ();
        miracle ())

let on_failure f =
  Delimcc.shift pt (fun cont ->
      try cont ()
      with Invalid ->
        f ();
        failure ())

let forall_length lengths values =
  List.init (forall lengths) (fun _ -> values ())

let forsome_length lengths values =
  List.init (forsome lengths) (fun _ -> values ())

let foratleast_length n lengths values =
  List.init (foratleast n lengths) (fun _ -> values ())
