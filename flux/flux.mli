(** Opérations sur les flux.

    Un flux est un générateur paresseux : cela permet de produire une
    quantité infinie d'information (par exemple une suite de nombres ou de
    lettres) avec une empreinte mémoire légère.*)

type 'a t
(** Un flux de ['a]. *)

(** {1 Manipulations élémentaires} *)

val empty : 'a t
(** Flux vide, qui se termine à la lecture du premier élément. *)

val cons : 'a -> 'a t -> 'a t
(** [cons v flux] ajoute [v] en tête du flux [flux]. *)

val uncons : 'a t -> ('a * 'a t) option
(** [uncons flux] récupère le premier élément du flux [flux], sous la forme
    d'une option :

    - [None] : le flux est terminé.
    - [Some (v, sequel)] : [v] est la valeur retirée du flux, et [sequel] est
      la suite du flux. *)

val append : 'a t -> 'a t -> 'a t
(** [append flux1 flux2] produit un unique flux qui est la concaténation de
    [flux1] puis [flux2]. Si [flux1] ne termine pas, les éléments de [flux2]
    ne seront jamais lu dans flux produit. *)

(** {1 Filtrage et modifications} *)

val filter : ('a -> bool) -> 'a t -> 'a t
(** [filter pr flux] produit un flux sans les éléments du flux [flux] valant
    [false] au prédicat [pr]. L'ordre des éléments est conservé. *)

val map : ('a -> 'b) -> 'a t -> 'b t
(** [map f flux] applique la fonction [f] à tous les éléments du flux [flux],
    pour produire un nouveau flux. *)

val apply : ('a -> 'b) t -> 'a t -> 'b t
(** [apply f_flux v_flux] applique un flux de fonctions [f_flux] à un flux
    d'éléments [v_flux] : la première fonction extraite de [f_flux] est
    appelée sur le premier élément extrait de [v_flux], la seconde sur le
    second... pour produire un nouveau flux.

    Par exemple

    {[
      let flux_fonctions = Flux.unfold (fun i -> Some(fun n -> n + i, i + 1)) 0 in
      let flux_entiers = Flux.unfold (fun n -> Some(n, n + 1)) 0 in
      let flux = Flux.apply flux_fonctions flux_entiers
    ]}

    produit le flux des entiers pairs.

    Le flux produit se termine lorsqu'un des deux flux se termine. *)

(** {1 Création d'un flux} *)

val constant : 'a -> 'a t
(** [constant v] produit un flux constant et infini de [v]. *)

val unfold : ('a -> ('b * 'a) option) -> 'a -> 'b t
(** [unfold f x] crée un flux à partir de la fonction [f] et de son argument
    initial [x].

    La fonction [f] renvoie une [option] :

    - Si c'est [None], le flux s'arrête.
    - Si c'est [Some (v, x)] alors [v] sera la valeur ajoutée au flux, et [x]
      l'argument de [f] pour générer la prochaine valeur du flux.

    Par exemple,

    {[ Flux.unfold (fun x -> if x <= 100 then Some (x, x + 2) else None) 50 ]}

    est le flux des entiers pairs de 50 à 100 inclus.

    On peut rendre ce flux infini,

    {[ Flux.unfold (fun x -> Some (x, x + 2)) 50 ]}

    mais attention à la terminaison du programme. *)

val of_list : 'a list -> 'a t
(** [of_list l] produit un flux à partir des éléments de [l] depuis la tête
    de la liste. *)

(** {1 Opérations supplémentaires} *)

val map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
(** [map2 f flux1 flux2] est similaire à {!map} mais la fonction [f] prend deux
    arguments, et par conséquent [map2] prend deux flux en argument. Le flux
    produit se termine lorsque [flux1] ou [flux2] se termine.

    Par exemple, si [flux1] et [flux2] sont deux flux d'entiers, on peut
    additionner leurs éléments deux à deux :

    {[ Flux.map2 (fun a b -> a + b) flux1 flux2 ]} *)
