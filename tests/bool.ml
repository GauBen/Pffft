(** Test des quantificateurs sur les booléens *)

let%test _ =
  Pffft.check
    Pffft.(fun () -> if forall_bool () then miracle () else miracle ())

let%test _ =
  not
    (Pffft.check
       Pffft.(fun () -> if forall_bool () then failure () else miracle ()))

let%test _ =
  not
    (Pffft.check
       Pffft.(fun () -> if forall_bool () then miracle () else failure ()))

let%test _ =
  not
    (Pffft.check
       Pffft.(fun () -> if forall_bool () then failure () else failure ()))

let%test _ =
  Pffft.check
    Pffft.(fun () -> if forsome_bool () then miracle () else miracle ())

let%test _ =
  Pffft.check
    Pffft.(fun () -> if forsome_bool () then failure () else miracle ())

let%test _ =
  Pffft.check
    Pffft.(fun () -> if forsome_bool () then miracle () else failure ())

let%test _ =
  not
    (Pffft.check
       Pffft.(fun () -> if forsome_bool () then failure () else failure ()))
