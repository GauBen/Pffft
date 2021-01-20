(** Programmation fonctionnelle : un fantastique framework de test.

    Cette bibliothèque fournit des fonctions de tests qui permettent d'écrire
    des tests avec des quantifieurs mathématiques.

    Il existe deux résultats possibles : une exécution est valide ou ne l'est
    pas. Une exécution est déclarée valide si elle se termine, ou si on la
    déclare explicitement valide. Une exécution est déclarée invalide si
    elle est interrompue par l'échec d'une assertion, ou si on la déclare
    explicitement invalide. *)

(** {1 Exécution d'une suite de tests} *)

val check : (unit -> unit) -> bool
(** Exécute un programme instrumenté avec les fonctions ci-dessous. Le
    resultat booléen représente la validité de l'exécution et permet de
    s'interfacer avec [let%test] de [ppx_inline_test].

    Il est conseillé de préfixer la fonction passée en argument avec [Pffft.]
    pour ne pas avoir à préfixer tous les appels :

    {[
      let%test _ =
        let is_lower c = c = Char.lowercase_ascii c in
        Pffft.check
          Pffft.(
            fun () ->
              let c = forall (Flux.of_list [ 'h'; 'e'; 'y'; 'H'; 'i' ]) in
              assertion (fun () -> is_lower c))
    ]}

    Dans l'exemple au dessus, {!forall} et {!assertion} ne sont pas préfixés.

    Dans cet exemple, la variable [c] va prendre les valeurs ['h'], ['e'], ['y']
    et passer l'assertion. Lorsque [c] va prendre la valeur ['H'], l'assertion
    va échouer et, comme l'assertion n'est pas vraie pour toutes les valeurs du
    flux, le test va échouer :

    {v
File "...": <<Pffft.check   (let open Pffft in      fun () [...]>> is false.
FAILED 1 / 1 test
    v}

    Au lieu de vérifier si l'assertion est vraie pour tout [c], on peut
    vérifier qu'il existe un [c] vérifiant l'assertion :

    {[
      let%test _ =
        let is_lower c = c = Char.lowercase_ascii c in
        Pffft.check
          Pffft.(
            fun () ->
              let c = forsome (Flux.of_list [ 'H'; 'E'; 'Y'; 'h'; 'I' ]) in
              assertion (fun () -> is_lower c))
    ]}

    Cette fois-ci, le test passe car il existe une valeur testée qui passe
    l'assertion, ['h']. *)

(** {1 Primitives d'interruption} *)

val miracle : unit -> 'a
(** Interrompt l'exécution et la rend valide.

    Cette primitive n'a pas de raison particulière d'être utilisée
    directement, mais on peut s'en servir pour rendre une suite d'instructions
    valide. *)

val failure : unit -> 'a
(** Interrompt l'exécution et la rend invalide. De même, [failure] n'a pas de
    raisson particulière d'être utilisée seule. *)

(** {1 Filtrage des exécutions} *)

val assumption : (unit -> bool) -> unit
(** Filtre et ne continue que les executions qui vérifient le prédicat passé
    en paramètre. Les autres exécutions sont simplement arrêtées et
    déclarées valides. Ceci correspond à la sémantique d'une précondition,
    i.e. on n'exécute un programme que si sa précondition est vraie, i.e. on
    ignore les autres exécutions.

    Par exemple, on peut exclure les cas où [a] ≥ [b] où les variables [a]
    et [b] sont définies auparavant : [assumption (fun () -> a < b)].

    On peut alors écrire des tests sous la forme :

    - Pour tout [a] dans un tel ensemble : [let a = forall (Flux.of_list e) in]
    - Pour tout [b] dans un autre ensemble :
      [let b = forall (Flux.of_list f) in]
    - Tels que [a] < [b] : [assumption (fun () -> a < b);]
    - ... *)

val assertion : (unit -> bool) -> unit
(** Filtre et ne continue que les executions qui vérifient le prédicat passé
    en paramètre. Les autres exécutions sont simplement arrêtées et
    déclarées invalides. Ceci correspond à la sémantique d'une
    postcondition, i.e. on ne valide l'exéecution que si la postcondition est
    vraie, i.e. les autres executions sont invalides et correspondent à une
    erreur.

    [assertion] correspond généralement à la propriété qu'on veut montrer,
    et est par conséquent souvent à la fin de la fonction testée. Des
    exemples sont donnés plus bas, à {!forall} et {!forsome}. *)

(** {1 Quantificateurs sur les booléens} *)

val forall_bool : unit -> bool
(** Crée deux exécutions de la suite du programme, renvoie [true] dans l'une
    et [false] dans l'autre. Pour que l'exécution parente soit valide, les deux
    exécutions filles doivent être valides.

    On peut mettre en évidence le {i fork} réalisé par [forall_bool] :

    {[
      let _ =
        Pffft.check (fun () ->
            let b = Pffft.forall_bool () in
            if b then print_endline "true" else print_endline "false")
    ]}

    L'exécution affiche [true false], preuve que deux exécutions sont
    lancées, l'une dans laquelle la variable [b] vaut [true] puis [false] dans
    l'autre.

    L'exécution est paresseuse, par conséquent si la première exécution
    échoue, la seconde ne sera pas lancée et l'exécution parente sera
    déclarée invalide. *)

val forsome_bool : unit -> bool
(** {i Forke} l'exécution courante en deux versions. Dans chacune de ces
    versions, [forsome_bool] renvoie un booléen différent. L'exécution
    parente est valide si et seulement si au moins une des deux exécutions
    filles l'est.

    L'exécution est paresseuse, si la première est valide, la seconde n'est
    pas lancée et l'exécution parente est déclarée valide. *)

(** {1 Quantificateurs sur les flux} *)

val forall : 'a Flux.t -> 'a
(** Exécute la suite pour chaque élément du flux passé en argument.

    [forall] correspond au quantificateur ∀ : on peut écrire « ∀ x ∈ E
    » avec le code [let x = forall (Flux.of_list e)], dans le cas où on
    représente l'ensemble E avec la liste [e].

    L'exécution n'est déclarée valide que si toutes les exécutions filles le
    sont. Si le flux est vide, l'exécution est déclarée valide. L'exécution
    est paresseuse : la première exécution fille invalide entraine
    l'invalidation de l'exécution parente.

    Par exemple, on peut créer une fonction qui vérifie la primalité des
    entiers :

    {[
      let is_prime n =
        let range a b =
          Flux.unfold (fun x -> if x <= b then Some (x, x + 1) else None) a
        in
        n >= 2
        && Pffft.check
             Pffft.(
               fun () ->
                 let i = forall (range 2 (n / 2)) in
                 assertion (fun () -> n mod i <> 0))
    ]}

    Cette fonction est la traduction directe de « n premier ⇔ pour tout i
    dans \[2; n/2\], i ne divise pas n ». *)

val forsome : 'a Flux.t -> 'a
(** Correspond au quantificateur ∃ : on peut écrire « ∃ x ∈ E » avec le
    code [let x = forsome (Flux.of_list e)], dans le cas où on représente
    l'ensemble E avec la liste [e].

    L'exécution n'est déclarée valide que si au moins une exécution fille
    l'est. Si le flux est vide, l'exécution est déclarée invalide.
    L'exécution est paresseuse : la première exécution fille valide entraine
    la validation de l'exécution parente.

    Par exemple, on peut créer une fonction qui vérifie qu'un ensemble
    contient un autre ensemble, dans le cas où on modélise les ensembles avec
    des listes sans doublon :

    {[
      let is_subset subset set =
        Pffft.check
          Pffft.(
            fun () ->
              let x = forall (Flux.of_list subset) in
              let y = forsome (Flux.of_list set) in
              assertion (fun () -> x = y))
    ]}

    Cette fonction est la traduction directe de « subset ⊂ set ⇔ ∀ x ∈
    subset, ∃ y ∈ set, x = y ». *)

val foratleast : int -> 'a Flux.t -> 'a
(** L'exécution parente est valide si est seulement si au moins [n] exécutions
    filles le sont. On a [Pffft.forsome = Pffft.foratleast 1].

    Par exemple, on peut s'en servir pour vérifier l'équivalence « a non
    premier ⇔ il existe au moins 3 diviseurs de a » :

    {[
      let%test _ =
        (* Produit un flux d'entier de l'intervale [a; b] contenant ses bornes. *)
        let range a b =
          Flux.unfold (fun x -> if x <= b then Some (x, x + 1) else None) a
        in
        (* Renvoie true si n est premier, false sinon. *)
        let is_prime n =
          let rec aux n i =
            if i * i > n then true else n mod i <> 0 && aux n (i + 1)
          in
          n >= 2 && aux n 2
        in
        Pffft.check
          Pffft.(
            fun () ->
              (* Pour tout a dans [2; 20] : *)
              let a = forall (range 2 20) in
              (* Disjonction de cas si a est premier : *)
              if is_prime a then
                (* Il existe au moins (a-2) nombres qui ne divisent pas a : *)
                let b = foratleast (a - 2) (range 1 a) in
                assertion (fun () -> a mod b <> 0)
              else
                (* Il existe au moins 3 nombres qui divisent a : *)
                let b = foratleast 3 (range 1 a) in
                assertion (fun () -> a mod b = 0))
    ]}

    Si [foratleast n f] est appelé avec [n <= 0], l'exécution est déclarée
    valide. Si [n > 0] et [f] est vide, l'exécution est déclarée invalide. *)

(** {1 Affichage des succès et des échecs} *)

(** Il est possible d'appeler une fonction de {i callback} sur une exécution,
    en fonction de son résultat. *)

val on_success : (unit -> unit) -> unit
(** Exécute la fonction passée en paramètre si et seulement si l'exécution
    courante est valide.

    On peut reprendre l'exemple de la fonction {!foratleast} pour ajouter
    l'affichage d'un message à chaque cas traité :

    {[
      let%test _ =
        (* Produit un flux d'entier de l'intervale [a; b] contenant ses bornes. *)
        let range a b =
          Flux.unfold (fun x -> if x <= b then Some (x, x + 1) else None) a
        in
        (* Renvoie true si n est premier, false sinon. *)
        let is_prime n =
          let rec aux n i =
            if i * i > n then true else n mod i <> 0 && aux n (i + 1)
          in
          n >= 2 && aux n 2
        in
        Pffft.check
          Pffft.(
            fun () ->
              let a = forall (range 2 6) in
              if is_prime a then (
                (* Message si l'assertion est vraie pour a premier *)
                on_success (fun () ->
                    Format.printf "%d est premier n'a que 2 diviseurs.@." a);
                let b = foratleast (a - 2) (range 1 a) in
                assertion (fun () -> a mod b <> 0))
              else (
                (* Message si l'assertion est vraie pour a non premier *)
                on_success (fun () ->
                    Format.printf
                      "%d n'est pas premier et a au moins 3 diviseurs.@." a);
                let b = foratleast 3 (range 1 a) in
                assertion (fun () -> a mod b = 0)))
    ]}

    L'exécution affiche :

    {v
2 est premier et n'a que 2 diviseurs.
3 est premier et n'a que 2 diviseurs.
4 n'est pas premier et a au moins 3 diviseurs.
5 est premier et n'a que 2 diviseurs.
6 n'est pas premier et a au moins 3 diviseurs.
    v} *)

val on_failure : (unit -> unit) -> unit
(** Exécute la fonction passée en paramètre si et seulement si l'exécution
    courante est invalide.

    Cela permet de savoir quels cas de tests ne sont pas valides.

    Par exemple, on pourrait être tenté de vérifier le théorème « tout
    nombre impair supérieur ou égal à 3 est premier » :

    {[
      (* Produit un flux d'entiers de l'intervale [a; b] contenant ses bornes. *)
      let range a b =
        Flux.unfold (fun x -> if x <= b then Some (x, x + 1) else None) a

      (* Utilisation de Pffft sur le théorème : *)
      let _ =
        if
          Pffft.check
            Pffft.(
              fun () ->
                (* Pour tout entier n dans [3; 99] : *)
                let n = forall (range 3 99) in
                (* tel que n impair : *)
                assumption (fun () -> n mod 2 = 1);
                on_success (fun () -> Format.printf "%d est premier.@." n);
                (* Pour tout entier p dans [2; n-1] : *)
                let p = forall (range 2 (n - 1)) in
                on_failure (fun () ->
                    Format.printf "Contre-exemple : %d divise %d.@." p n);
                (* p ne divise pas n : *)
                assertion (fun () -> n mod p <> 0))
        then print_endline "Le théorème est vrai jusqu'à 99."
        else print_endline "Le théorème est faux."
    ]}

    L'exécution affiche :

    {v
3 est premier.
5 est premier.
7 est premier.
Contre-exemple : 3 divise 9.
Le théorème est faux.
    v} *)

(** {1 Quantificateurs sur les longueurs de liste} *)

val forall_length : int Flux.t -> (unit -> 'a) -> 'a list
(** [forall_length lengths values] produit des listes de longueur issue du flux
    [lengths], avec les valeurs produites par [values], et vérifie que la suite
    de l'exécution est valide pour toutes les longueurs produites.

    [values] peut être une fonction constante [fun () -> 'a'] ou une fonction
    plus complexe [fun () -> forall (Flux.of_list \['a'; 'b'\])].

    On peut vérifier que, sur les listes de longueur impaire contenant des
    ['a'] ou des ['b'], il y a toujours un nombre pair d'un des deux éléments
    :

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
          (fun () -> forall (Flux.of_list [ 'a'; 'b' ]))
      in
      assertion (fun () -> count l 'a' mod 2 = 0 || count l 'b' mod 2 = 0)
    ]}

    Attention, le quantificateur utilisé pour produire les valeurs de la liste
    doit être vérifié :

    {[
      let l =
        forall_length
          (Flux.of_list [ 1; 2 ])
          (fun () -> forall (Flux.of_list [ 'a'; 'b' ]))
      in
      assertion (fun () -> p l)
    ]}

    va vérifier la propriété
    [(p \['a'\] && p \['b'\]) && (p \['a'; 'a'\] && p \['a'; 'b'\] && p \['b'; 'a'\] && p \['b'; 'b'\])].

    Alors que

    {[
      let l =
        forall_length
          (Flux.of_list [ 1; 2 ])
          (fun () -> forsome (Flux.of_list [ 'a'; 'b' ]))
      in
      assertion (fun () -> p l)
    ]}

    va vérifier la propriété
    [(p \['a'\] || p \['b'\]) && (p \['a'; 'a'\] || p \['a'; 'b'\] || p \['b'; 'a'\] || p \['b'; 'b'\])].

    L'exécution est paresseuse, et est déclarée invalide à la première
    erreur. Si le flux des longueurs est vide, l'exécution est déclarée
    valide. *)

val forsome_length : int Flux.t -> (unit -> 'a) -> 'a list
(** [forsome_length lengths values] produit des listes de longueur issue du flux
    [lengths] avec les valeurs produites par [values], et vérifie que la suite
    de l'exécution est valide pour au moins une des longueurs produites.

    On peut par exemple vérifier que « x dans une liste l ⇔ il existe l1, l2
    de longeur 0, 1, 2 ou 3 telles que l = l1\@(x::l2) » :

    {[
      let%test _ =
        let lengths = Flux.of_list [ 0; 1; 2; 3 ] in
        let values = Flux.of_list [ 'a'; 'b'; 'c' ] in
        Pffft.check
          Pffft.(
            fun () ->
              let l = forall_length lengths (fun () -> forall values) in
              let x = forall values in
              let l1 = forsome_length lengths (fun () -> forsome values) in
              let l2 = forsome_length lengths (fun () -> forsome values) in
              let r = List.mem x l in
              assertion (fun () -> r = (l = l1 @ (x :: l2))))
    ]}

    Attention, le quantificateur utilisé pour produire les valeurs de la liste
    doit être vérifié :

    {[
      let l =
        forsome_length
          (Flux.of_list [ 1; 2 ])
          (fun () -> forall (Flux.of_list [ 'a'; 'b' ]))
      in
      assertion (fun () -> p l)
    ]}

    va vérifier la propriété
    [(p \['a'\] && p \['b'\]) || (p \['a'; 'a'\] && p \['a'; 'b'\] && p \['b'; 'a'\] && p \['b'; 'b'\])].

    Alors que

    {[
      let l =
        forsome_length
          (Flux.of_list [ 1; 2 ])
          (fun () -> forsome (Flux.of_list [ 'a'; 'b' ]))
      in
      assertion (fun () -> p l)
    ]}

    va vérifier la propriété
    [(p \['a'\] || p \['b'\]) || (p \['a'; 'a'\] || p \['a'; 'b'\] || p \['b'; 'a'\] || p \['b'; 'b'\])].

    L'exécution est paresseuse, et est déclarée valide au premier succès. Si
    le flux des longueurs est vide, l'exécution est déclarée invalide. *)

val foratleast_length : int -> int Flux.t -> (unit -> 'a) -> 'a list
(** [foratleast_length n lengths values] produit des listes de longueur issue du
    flux [lengths] avec les valeurs produites par [values], et vérifie que la
    suite de l'exécution est valide pour au moins [n] listes produites. On a
    [Pffft.forsome_length = Pffft.foratleast_length 1].

    Les spécifications sont similaires à {!foratleast} : si [n <= 0],
    l'exécution est déclarée valide. Si [n > 0] et que [lengths] et vide,
    l'exécution est déclarée invalide. *)
