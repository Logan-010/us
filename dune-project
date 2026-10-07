(lang dune 3.23)

(name us)

(generate_opam_files true)

(source
 (github Logan-010/us))

(authors "Logan-010")

(maintainers "Logan-010")

(license UNLICENSE)

(documentation https://github.com/Logan-010/us)

(package
 (name us)
 (synopsis "Private URL shortener")
 (description
  "Private URL shortener designed for personal use (and preferablly behind a https proxy)")
 (depends ocaml toml dream dokeysto)
 (tags
  ("url-shortener" "http" "server")))
