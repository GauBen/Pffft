(** Test de Pffft.foratleast *)

let values = Flux.(cons 1 (cons 2 (cons 3 (cons 4 empty))))

(* Cas valides *)
let%test _ =
  Pffft.check
    Pffft.(
      fun () ->
        let a = foratleast 1 values in
        assertion (fun () -> a mod 4 = 0))

let%test _ =
  Pffft.check
    Pffft.(
      fun () ->
        let a = foratleast 2 values in
        assertion (fun () -> a mod 2 = 0))

let%test _ =
  Pffft.check
    Pffft.(
      fun () ->
        let a = foratleast 3 values in
        assertion (fun () -> a > 1))

let%test _ =
  Pffft.check
    Pffft.(
      fun () ->
        let a = foratleast 4 values in
        assertion (fun () -> a > 0))

(* Cas invalides *)
let%test _ =
  not
    (Pffft.check
       Pffft.(
         fun () ->
           let a = foratleast 1 values in
           assertion (fun () -> a > 5)))

let%test _ =
  not
    (Pffft.check
       Pffft.(
         fun () ->
           let a = foratleast 2 values in
           assertion (fun () -> a = 1)))

let%test _ =
  not
    (Pffft.check
       Pffft.(
         fun () ->
           let a = foratleast 3 values in
           assertion (fun () -> a > 2)))

let%test _ =
  not
    (Pffft.check
       Pffft.(
         fun () ->
           let a = foratleast 5 values in
           assertion (fun () -> a > 0)))
