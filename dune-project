(lang dune 2.7)

(name pffft)

(generate_opam_files true)

(license MIT)

(authors "https://github.com/GauBen/Pffft/graphs/contributors")

(maintainers "https://github.com/GauBen/Pffft/graphs/contributors")

(source
 (github GauBen/Pffft))

(bug_reports "https://github.com/GauBen/Pffft/issues")

(homepage "https://github.com/GauBen/Pffft")

(documentation "https://github.com/GauBen/Pffft")

(package
 (name pffft)
 (synopsis "Programmation fonctionnelle : un fantastique framework de test")
 (depends
  (ppx_inline_test :with-test)
  (ocaml
   (>= 4.11.0))
  dune))
