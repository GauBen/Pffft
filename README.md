# Pffft

_Programmation fonctionnelle : un fantastique framework de test._

**→ [Consulter la documentation.](http://gauben.github.io/Pffft/)**

## Introduction

Comme 3, 5 et 7 sont des nombres premiers, on pourrait être tenter de démontrer le théorème « Tout nombre impair supérieur ou égal à 3 est premier ».

Mathématiquement, on l'écrit :

[$\forall n \in \N \text{ tel que } n \ge 3 \text{ et } n \text{ impair,}\\ \forall p \in \N \text{ tel que } 2 \le p \lt n,\\ n \not\equiv 0 \pmod p$](<https://katex.org/?data=%7B%22displayMode%22%3Atrue%2C%22leqno%22%3Afalse%2C%22fleqn%22%3Afalse%2C%22throwOnError%22%3Atrue%2C%22errorColor%22%3A%22%23cc0000%22%2C%22strict%22%3A%22warn%22%2C%22output%22%3A%22htmlAndMathml%22%2C%22trust%22%3Afalse%2C%22macros%22%3A%7B%22%5C%5Cf%22%3A%22%231f(%232)%22%7D%2C%22code%22%3A%22%5C%5Cforall%20n%20%5C%5Cin%20%5C%5CN%20%5C%5Ctext%7B%20tel%20que%20%7D%20n%20%5C%5Cge%203%20%5C%5Ctext%7B%20et%20%7D%20n%20%5C%5Ctext%7B%20impair%2C%7D%5C%5C%5C%5C%20%5C%5Cforall%20p%20%5C%5Cin%20%5C%5CN%20%5C%5Ctext%7B%20tel%20que%20%7D%202%20%5C%5Cle%20p%20%5C%5Clt%20n%2C%5C%5C%5C%5C%20n%20%5C%5Cnot%5C%5Cequiv%200%20%5C%5Cpmod%20p%22%7D>)

Pffft permet de d'affirmer ou d'infirmer la véracité d'un tel théorème pour un ensemble de valeurs, par exemple pour les nombres impairs de 3 à 99.

On peut le formuler avec Pffft de la façon suivante :

```ocaml
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
```

L'exécution affiche :

```
3 est premier.
5 est premier.
7 est premier.
Contre-exemple : 3 divise 9.
Le théorème est faux.
```

## Utilisation

Pffft s'utilise comme une bibliothèque [opam](https://opam.ocaml.org/).

Pour ajouter les dépendances au gestionnaires de paquets opam :

```
$ opam pin add delimcc git+https://github.com/GauBen/delimcc
$ opam pin add pffft git+https://github.com/GauBen/Pffft
$ opam install pffft
```

Pour ajouter les dépendances au projet à tester [avec dune](https://dune.readthedocs.io/en/stable/concepts.html#library-dependencies) :

```lisp
(executable/library
 (name ...)
 (libraries ... pffft ...))
```

[Vous pouvez vous inspirer du répertoire `test`.](https://github.com/GauBen/Pffft/tree/main/tests)

Une fois installé, vous pouvez utiliser les bibliothèques `Pffft`, qui propose les quantificateurs, et `pffft.Flux`, qui permet de manipuler des flux de données.

**→ [Consulter la documentation.](http://gauben.github.io/Pffft/)**

## Développement

Ce projet utilise les outils [opam](https://opam.ocaml.org/) et [dune](https://dune.readthedocs.io/en/stable/).

Versions conseillées :

- OCaml 4.11.1
- opam 2.0.5
- dune 2.7.1

Environnement de développement conseillé : [VS Code](https://code.visualstudio.com/) avec [OCaml Platform](https://marketplace.visualstudio.com/items?itemName=ocamllabs.ocaml-platform) sur Linux.

**Il est indispensable d'utiliser une version patchée de delimcc qui supprime la verbosité excessive !**
Vous pouvez utiliser la commande ci-dessous, qui installe une version patchée, compatible avec OCaml 4.11.1 :

```bash
$ opam pin add delimcc git+https://github.com/GauBen/delimcc
```

### Lancer les tests

```bash
$ dune runtest
```

### Produire la documentation

```bash
$ dune build @doc
$ $BROWSER _build/default/_doc/_html/index.html
```
