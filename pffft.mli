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

val hmmm : bool
