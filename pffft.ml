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

let rec forall flux =
  match Flux.uncons flux with
  | Some (v, suite) -> if forall_bool () then v else forall suite
  | None -> miracle ()

let rec forsome flux =
  match Flux.uncons flux with
  | Some (v, suite) -> if forsome_bool () then v else forsome suite
  | None -> failure ()

let rec foratleast n flux =
  if n <= 0 then miracle ();
  match Flux.uncons flux with
  | Some (v, suite) -> (
      match
        Delimcc.shift pt (fun cont ->
            try cont None with
            | Valid -> cont (Some (n - 1))
            | Invalid -> cont (Some n))
      with
      | None -> v
      | Some n -> foratleast n suite)
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
  | Invalid -> false
