{
  description = "US Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        ocamlPackages = pkgs.ocamlPackages;

        dokeysto = ocamlPackages.buildDunePackage {
          pname = "dokeysto";
          version = "unstable-2025-09-22";

          src = pkgs.fetchFromGitHub {
            owner = "UnixJunkie";
            repo = "dokeysto";

            rev = "50117deffb9a200e8642fb97e4aca4cbd203546a";

            hash = "sha256-heWsDcn2eJyKoR0Rz/WjJAbMbtHH2EkV3tI/JQsk7mE=";
          };

          duneVersion = "3";

          propagatedBuildInputs = with ocamlPackages; [
            extunix
          ];
        };
      in
      {
        packages.default = ocamlPackages.buildDunePackage {
          pname = "us";
          version = "0.1.0";

          src = ./.;

          duneVersion = "3";

          propagatedBuildInputs = with ocamlPackages; [
            dream
            dokeysto
            toml
          ];

          nativeBuildInputs = [
            pkgs.pkg-config
          ];
        };

        devShells.default = pkgs.mkShell {
          packages = [
            ocamlPackages.ocaml
            ocamlPackages.dune_3
            ocamlPackages.ocaml-lsp
            ocamlPackages.ocamlformat
            ocamlPackages.utop
            ocamlPackages.findlib
            ocamlPackages.dream
            dokeysto
            ocamlPackages.toml
          ];
        };
      }
    );
}
