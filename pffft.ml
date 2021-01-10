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
  | Some (v, suite) -> if forall_bool () then v else forall suite
  | None -> miracle ()

let rec forsome values =
  match Flux.uncons values with
  | Some (v, suite) -> if forsome_bool () then v else forsome suite
  | None -> failure ()

let rec foratleast n values =
  if n <= 0 then miracle ();
  match Flux.uncons values with
  | Some (v, suite) -> (
      match
        Delimcc.shift pt (fun cont ->
            try cont None with
            | Valid -> cont (Some (n - 1))
            | Invalid -> cont (Some n))
      with
      | None -> v
      | Some n -> foratleast n suite )
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

let rec forall_length lengths values =
  match Flux.uncons lengths with
  | Some (v, suite) ->
      if forall_bool () then List.init v (fun _ -> values ())
      else forall_length suite values
  | None -> miracle ()

let rec forsome_length lengths values =
  match Flux.uncons lengths with
  | Some (v, suite) ->
      if forsome_bool () then List.init v (fun _ -> values ())
      else forsome_length suite values
  | None -> failure ()

let rec foratleast_length n lengths values =
  if n <= 0 then miracle ();
  match Flux.uncons lengths with
  | Some (v, suite) -> (
      match
        Delimcc.shift pt (fun cont ->
            try cont None with
            | Valid -> cont (Some (n - 1))
            | Invalid -> cont (Some n))
      with
      | None -> List.init v (fun _ -> values ())
      | Some n -> foratleast_length n suite values )
  | None -> failure ()
