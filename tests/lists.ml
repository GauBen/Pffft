(* Pour toute liste l de longueur dans [0; 1; 2; 3] et d'éléments 'a', 'b' ou
   'c', x = 'a', 'b' ou 'c',

   x dans l <=> il existe l1, l2 de longeur 0, 1, 2 ou 3 telles que l =
   l1@(x::l2). *)
let%test _ =
  let lengths = Flux.(cons 0 (cons 1 (cons 2 (cons 3 empty)))) in
  let values = Flux.(cons 'a' (cons 'b' (cons 'c' empty))) in
  Pffft.check
    Pffft.(
      fun () ->
        let l = forall_length lengths (fun () -> forall values) in
        let x = forall values in
        let l1 = forsome_length lengths (fun () -> forsome values) in
        let l2 = forsome_length lengths (fun () -> forsome values) in
        let r = List.mem x l in
        assertion (fun () -> r = (l = l1 @ (x :: l2))))

(* Une liste de longueur impaire avec 2 éléments différents contient toujours un
   des deux éléments en nombre pair *)
let%test _ =
  let letters = Flux.(cons 'a' (cons 'b' empty)) in
  let odd_numbers =
    Flux.unfold (fun x -> if x <= 9 then Some (x, x + 2) else None) 1
  in
  let rec count l x =
    match l with
    | [] -> 0
    | t :: q when t = x -> 1 + count q x
    | _ :: q -> count q x
  in
  Pffft.check
    Pffft.(
      fun () ->
        let l = forall_length odd_numbers (fun () -> forall letters) in
        assertion (fun () -> count l 'a' mod 2 = 0 || count l 'b' mod 2 = 0))

(* Il existe l une liste de longueur 1, 2 ou 3 et de 'a' ou 'b', telle que l = [
   'a'; 'a'; 'a' ] *)
let%test _ =
  let letters = Flux.(cons 'a' (cons 'b' empty)) in
  let lengths = Flux.(cons 1 (cons 2 (cons 3 empty))) in
  Pffft.check
    Pffft.(
      fun () ->
        let l = forsome_length lengths (fun () -> forsome letters) in
        assertion (fun () -> l = [ 'a'; 'a'; 'a' ]))

(* Il existe une liste de longueur 1, 2 ou 3 telle que quels que soient ses
   éléments dans ['a'; 'b'], cette liste est de longueur 2. *)
let%test _ =
  let letters = Flux.(cons 'a' (cons 'b' empty)) in
  let lengths = Flux.(cons 1 (cons 2 (cons 3 empty))) in
  Pffft.check
    Pffft.(
      fun () ->
        let l = forsome_length lengths (fun () -> forall letters) in
        assertion (fun () -> match l with [ _; _ ] -> true | _ -> false))

(* Il N'existe PAS l une liste de longueur 1, 2 ou 3 telle que quels que soient
   ses éléments dans ['a'; 'b'], l = [ 'a'; 'a'; 'a' ] *)
let%test _ =
  let letters = Flux.(cons 'a' (cons 'b' empty)) in
  let lengths = Flux.(cons 1 (cons 2 (cons 3 empty))) in
  not
    (Pffft.check
       Pffft.(
         fun () ->
           let l = forsome_length lengths (fun () -> forall letters) in
           assertion (fun () -> l = [ 'a'; 'a'; 'a' ])))

(* Test de foratleast_length *)
let%test _ =
  let lengths = Flux.(cons 1 (cons 2 (cons 3 empty))) in
  Pffft.check
    Pffft.(
      fun () ->
        let l = foratleast_length 2 lengths (fun () -> 'a') in
        assertion (fun () -> List.length l > 1))

let%test _ =
  let lengths = Flux.(cons 1 (cons 2 (cons 3 empty))) in
  not
    (Pffft.check
       Pffft.(
         fun () ->
           let l = foratleast_length 2 lengths (fun () -> 'a') in
           assertion (fun () -> List.length l > 2)))
