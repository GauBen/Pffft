(** Test des quantificateurs sur les flux vides *)

let%test _ =
  Pffft.check
    Pffft.(
      fun () ->
        let _ = forall Flux.empty in
        ())

let%test _ =
  not
    (Pffft.check
       Pffft.(
         fun () ->
           let _ = forsome Flux.empty in
           ()))

let%test _ =
  not
    (Pffft.check
       Pffft.(
         fun () ->
           let n = forall (Flux.of_list [ 1; 2; 3; 10 ]) in
           let _ = foratleast n Flux.empty in
           ()))

let%test _ =
  Pffft.check
    Pffft.(
      fun () ->
        let n = forall (Flux.of_list [ -10; -1; 0 ]) in
        let _ = foratleast n Flux.empty in
        ())

let%test _ =
  Pffft.check
    Pffft.(
      fun () ->
        let _ = forall_length Flux.empty (fun () -> true) in
        ())

let%test _ =
  not
    (Pffft.check
       Pffft.(
         fun () ->
           let _ = forsome_length Flux.empty (fun () -> 'a') in
           ()))

let%test _ =
  not
    (Pffft.check
       Pffft.(
         fun () ->
           let n = forall (Flux.of_list [ 1; 2; 3; 10 ]) in
           let _ = foratleast_length n Flux.empty (fun () -> 'a') in
           ()))

let%test _ =
  Pffft.check
    Pffft.(
      fun () ->
        let n = forall (Flux.of_list [ -10; -1; 0 ]) in
        let _ = foratleast_length n Flux.empty (fun () -> 'a') in
        ())
