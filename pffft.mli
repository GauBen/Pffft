(** Programmation fonctionnelle : un fantastique framework de test.*)

val assumption : (unit -> bool) -> unit
(** Filtre et ne continue que les executions qui vérifient le prédicat passé
    en paramètre. Les autres exécutions sont simplement arrêtées et
    déclarées valides. Ceci correspond à la sémantique d'une précondition,
    i.e. on n'exécute un programme que si sa précondition est vraie, i.e. on
    ignore les autres exécutions. *)

val assertion : (unit -> bool) -> unit
(** Filtre et ne continue que les executions qui vérifient le prédicat passé
    en paramètre. Les autres exécutions sont simplement arrêtées et
    déclarées invalides. Ceci correspond à la sémantique d'une
    postcondition, i.e. on ne valide l'exéecution que si la postcondition est
    vraie, i.e. les autres executions sont invalides et correspondent à une
    erreur. *)

val miracle : unit -> 'a
(** Interrompt l'exécution et la rend valide (sans renvoyer de valeur). *)

val failure : unit -> 'a
(** Interrompt l'exécution et la rend invalide (sans renvoyer de valeur). *)

val forall_bool : unit -> bool
(** Forke l'exécution courante en deux versions. Dans chacune de ces versions,
    [forall_bool] renvoie un booleen différent. L'exécution parente est valide
    si et seulement si les deux exécutions filles le sont. *)

val forsome_bool : unit -> bool
(** Forke l'exécution courante en deux versions. Dans chacune de ces versions,
    [forsome_bool] renvoie un booleen différent. L'exécution parente est
    valide si et seulement si au moins une des deux exécutions filles le sont. *)

val forall : 'a Flux.t -> 'a
(** Genéralise [forall_bool] et forke l'exécution courante en autant de
    versions qu'il y a d'éléments dans le flux. *)

val forsome : 'a Flux.t -> 'a
(** Genéralise [forsome_bool] et forke l'exécution courante en autant de
    versions qu'il y a d'éléments dans le flux. *)

val foratleast : int -> 'a Flux.t -> 'a
(** Forke de la même façon l'exécution courante. L'exécution parente est
    valide si est seulement si au moins [n] exécutions filles le sont. On a
    [Pffft.forsome = Pffft.foratleast 1]. *)

val check : (unit -> unit) -> bool
(** Exécute un programme instrumenté avec les primitives ci-dessus. Le
    resultat booléen représente la validité de l'exécution et permet de
    s'interfacer avec [let%test] de [ppx_inline_test].*)

val on_success : (unit -> unit) -> unit
(** Exécute la fonction passée en paramètre si et seulement si l'exécution
    courante est valide. *)

val on_failure : (unit -> unit) -> unit
(** Exécute la fonction passée en paramètre si et seulement si l'exécution
    courante est invalide. *)

val forall_length : int Flux.t -> (unit -> 'a) -> 'a list
(** [forall_length lengths values] produit des listes de longueur issue du flux
    [lengths] avec les valeurs produites par [values], et vérifie que la suite
    de l'exécution est valide pour toutes les listes produites.

    On peut vérifier que sur les listes de longueur impaire contenant des ['a']
    ou des ['b'], il y a toujours un nombre pair d'un des deux éléments :

    {[
      let rec count l x =
        match l with
        | [] -> 0
        | t :: q when t = x -> 1 + count q x
        | _ :: q -> count q x
      in
      let l =
        forall_length
          (Flux.unfold (fun x -> if x <= 10 then Some (x, x + 2) else None) 1)
          (fun () -> forall Flux.(cons 'a' (cons 'b' empty)))
      in
      assertion (fun () -> count l 'a' mod 2 = 0 || count l 'b' mod 2 = 0)
    ]} *)

val forsome_length : int Flux.t -> (unit -> 'a) -> 'a list
(** [forsome_length lengths values] produit des listes de longueur issue du flux
    [lengths] avec les valeurs produites par [values], et vérifie que la suite
    de l'exécution est valide pour au moins une des listes produites. *)

val foratleast_length : int -> int Flux.t -> (unit -> 'a) -> 'a list
(** [foratleast_length n lengths values] produit des listes de longueur issue du
    flux [lengths] avec les valeurs produites par [values], et vérifie que la
    suite de l'exécution est valide pour au moins [n] listes produites. On a
    [Pffft.forsome_length = Pffft.foratleast_length 1]. *)
