# Rapport du projet de programmation fonctionnelle

Projet du groupe Guillaume Claverie, Corentin Dominguez, Théo Petit et Gautier Ben Aïm.

Pour des raisons que nous garderons secrètes, nous avons nommé la bibliothèque « Pffft », qui est l'acronyme de « Programmation fonctionnelle : un fantastique framework de test ». Ce trait d'humour n'est, nous l'espérons, pas sanctionnable.

## Introduction

Une introduction avec un exemple est donnée dans le fichier README.md.

## Choix de conception

On souhaite séparer les exécutions valides des exécutions invalides. Comme il n'y a que deux types d'exécutions, le type `bool` natif d'OCaml est adéquat. On aurait pu créer un type `type result = Invalid | Valid`, mais l'utilisation d'un type natif permet d'utiliser les opérateurs binaires `&&` et `||`.

Par conséquent, l'interruption de l'exécution pour la déclarer valide est aussi simple que :

```ocaml
let miracle () = Delimcc.shift prompt (fun _ -> true)
```

De même, vérifier que deux exécutions filles sont valides se fait directement avec `&&` :

```ocaml
let forall_bool () = Delimcc.shift prompt (fun cont -> cont true && cont false)
```

L'utilisation de `&&` permet en plus de bénéficier d'une exécution paresseuse sans code particulier.

Les primitives `forall` et `forsome` découlent directement de `forall_bool` et `forsome_bool` avec une construction récursive qui permet de dépiler le flux. La construction de `foratleast` est plus intéressante :

```ocaml
let rec foratleast n values =
  match (n, Flux.uncons values) with
  | i, Some (v, sequel) when i > 0 ->
      (* On forke deux fois, et selon la valeur de [successful], on sait si la
         première exécution fille est valide ou invalide *)
      let sucessful = forsome_bool () in
      if forall_bool () && sucessful then v
      else foratleast (if sucessful then n - 1 else n) sequel
  (* "Il existe au moins n" est faux si [values] est vide *)
  | i, None when i > 0 -> failure ()
  (* "Il existe au moins n" est vrai pour n <= 0 *)
  | _ -> miracle ()
```

On exploite `forsome_bool` et `forall_bool` :

- Si `forsome_bool ()` et `forall_bool ()` valent vrai, on est dans la première exécution
- Si `forsome_bool ()` vaut faux et `forall_bool ()` vaut vrai, alors la première exécution a échoué
- Si `forsome_bool ()` vaut vrai et `forall_bool ()` vaut faux, alors la première exécution a réussi
- Le cas où les deux valent faux n'est pas possible

Les contrats et les cas limites des fonctions sont détaillés dans la documentation : https://gauben.github.io/Pffft/pffft/.

## Extensions développées

Les deux extensions ont été développées, documentées et testées.

- Quantificateurs sur les longueurs de liste : https://gauben.github.io/Pffft/pffft/Pffft/#quantificateurs-sur-les-longueurs-de-liste

  Leur implémentation est directe depuis `forall`, `forsome` et `foratleast`.

- Affichage des succès et des échecs : https://gauben.github.io/Pffft/pffft/Pffft/#affichage-des-succ%C3%A8s-et-des-%C3%A9checs

  Pour ajouter les _callbacks_, le type de retour a été modifié en une paire `bool * (unit -> unit) list`. Les fonctions `forall_bool` et `forsome_bool` s'occupent de fusionner les listes produites par les exécutions.

  L'ordre d'appel des _callbacks_ a été ajouté à la suite de tests :

  ```ocaml
  let%test _ =
    let l = ref [] in
    let _ =
      Pffft.check
        Pffft.(
          fun () ->
            on_success (fun () -> l := 0 :: !l);
            let _ = forall_bool () in
            on_success (fun () -> l := 1 :: !l);
            let b = forsome_bool () in
            on_failure (fun () -> l := 2 :: !l);
            on_success (fun () -> l := 3 :: !l);
            assertion (fun () -> not b))
    in
    !l = [ 3; 2; 1; 3; 2; 1; 0 ]
  ```

## Packaging et documentation

Le projet a été développé conformément aux contraintes de développement des paquets opam, avec une bibliothèque principale, des dépendances, des tests et une documentation. Toutes les bibliothèques ont une interface `.mli` qui sert à produire la documentation et une implémentation concrète `.ml`.

- Un README avec des exemples et les consignes d'installation est disponible en page d'accueil du dépôt GitHub : https://github.com/GauBen/Pffft/
- La bibliothèque principale est documentée à cette adresse : https://gauben.github.io/Pffft/pffft/Pffft/
- La bibliothèque `Flux` est documentée à cette adresse : https://gauben.github.io/Pffft/pffft/Flux/
- Le projet est contrôlé par des GitHub Actions qui lancent les tests et produisent la documentation à chaque commit : https://github.com/GauBen/Pffft/blob/main/.github/workflows/continuous-deployment.yml
- Le projet est installable comme toutes les bibliothèques opam : https://github.com/GauBen/Pffft#utilisation

## Tests

Les tests assurent une couverture de 100% du code source du projet : https://gauben.github.io/Pffft/coverage/.

Tous les exemples donnés dans la documentation sont aussi testés.

Les tests sont écrits avec `ppx_inline_test` et la couverture est déterminée par `bisect_ppx`.

## Utilisations possibles

On peut envisager d'utiliser Pffft pour :

- Chercher des exemples et des contre-exemples à un théorème, comme dans l'introduction.

- Écrire des tests unitaires, par exemple pour la fonction `foratleast`.

```ocaml
let%test _ =
  not
    (Pffft.check
       Pffft.(
         fun () ->
           let n = forall (Flux.of_list [ 1; 2; 3; 10 ]) in
           let _ = foratleast n Flux.empty in
           ()))
```

- Créer des fonctions qui exploitent des propriétés mathématiques.

```ocaml
let is_prime n =
  n >= 2
  && Pffft.check
      Pffft.(
        fun () ->
          let i = forall (range 2 (n / 2)) in
          assertion (fun () -> n mod i <> 0))
```

## Remarques concernant la bibliothèque delimcc

La bibliothèque est distribuée sous la forme d'une archive `.tgz` sur le site du développeur : http://okmij.org/ftp/continuations/implementations.html. Il n'y a pas de gestion de versions, pas de journal des modifications, pas d'intégration à opam, pas de système de compilation moderne. Par conséquent, un autre développeur a pris le temps de publier le code sur GitHub et la bibliothèque sur opam (https://github.com/zinid/delimcc). Cependant, ce dépôt n'est pas à jour, et le développeur est inactif ; la dernière version à jour de delimcc est celle de ce dépôt, https://github.com/GauBen/delimcc, avec des corrections apportées par notre groupe.

Pour l'installer, le plus simple est d'ajouter une épingle à opam :

```console
$ opam pin add delimcc git+https://github.com/GauBen/delimcc
```

Si vous souhaitez continuer à utiliser cette bibliothèque dans votre cours, nous vous conseillons de prendre contact avec le développeur d'origine de delimcc pour mettre en place une architecture OCaml/opam/dune/déploiement continu similaire à celle de Pffft.

## Conclusion

Ce projet a été l'occasion de découvrir l'environnement OCaml dans une plus large mesure que pendant les TP, en utilisant les outils opam, dune, odoc et bisect_ppx.
