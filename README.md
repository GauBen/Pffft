# Pffft

Programmation fonctionnelle : un fantastique framework de test.

Ce projet utilise les outils [opam](https://opam.ocaml.org/) et [dune](https://dune.readthedocs.io/en/stable/).

Versions conseillées :

- OCaml 4.11.1
- opam 2.0.5
- dune 2.7.1

Environnement de développement conseillé : [VS Code](https://code.visualstudio.com/) avec [OCaml Platform](https://marketplace.visualstudio.com/items?itemName=ocamllabs.ocaml-platform) sur Linux.

**Il est indispensable d'utiliser une version patchée de delimcc qui supprime la verbosité excessive !**
Vous pouvez utiliser la commande ci-dessous, qui installe une version patchée, compatible avec OCaml 4.11.1 :

```bash
$ opam pin add delimcc git+https://github.com/GauBen/delimcc
```

## Lancer les tests

```bash
$ dune runtest
```

## Produire la documentation

```bash
$ dune build @doc
$ $BROWSER _build/default/_doc/_html/index.html
```
