{
  description = "Agentic AI Assistant working for https://www.vorburger.ch";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Nix sandbox has no network access; this wrapper checks local links only.
        packages.lychee-offline = pkgs.writeShellScriptBin "lychee-offline" ''
          exec ${pkgs.lychee}/bin/lychee --offline "$@"
        '';

        # TODO: Upstream skills-ref to nixpkgs
        packages.skills-ref = pkgs.python3Packages.buildPythonApplication {
          pname = "skills-ref";
          version = "0.1.0";
          pyproject = true;

          src = pkgs.fetchFromGitHub {
            owner = "agentskills";
            repo = "agentskills";
            rev = "b5ce2a438123f9f9c9b167c5af297c048f15395b";
            hash = "sha256-s01Gh5h4r9596G0ap25zbHDrctYeW8pHaqfmE8xMtno=";
          };

          sourceRoot = "source/skills-ref";

          nativeBuildInputs = [
            pkgs.python3Packages.hatchling
          ];

          propagatedBuildInputs = [
            pkgs.python3Packages.click
            pkgs.python3Packages.strictyaml
          ];

          # There are no tests in the subfolder for now
          doCheck = false;
        };

        # Build the static website using https://zensical.org
        packages.website = pkgs.runCommand "aifiles-website" {
          buildInputs = [ pkgs.zensical ];
        } ''
          cp -r ${self}/docs docs
          chmod -R u+w docs
          cp ${self}/zensical.toml zensical.toml
          zensical build --clean
          cp -r site $out
        '';

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            markdownlint-cli2
            lychee
            pre-commit
            git-lfs
            zensical
            self'.packages.skills-ref
          ];
          shellHook = ''
            pre-commit install
          '';
        };

        checks = {
          markdownlint = pkgs.runCommand "markdownlint" {
            buildInputs = [ pkgs.markdownlint-cli2 ];
          } ''
            cd ${self}
            markdownlint-cli2 .
            touch $out
          '';

          lychee = pkgs.runCommand "lychee" {
            buildInputs = [ self'.packages.lychee-offline pkgs.cacert ];
          } ''
            cd ${self}
            lychee-offline .
            touch $out
          '';

          skills-validate = pkgs.runCommand "skills-validate" {
            buildInputs = [ self'.packages.skills-ref ];
          } ''
            cd ${self}/skills
            for skill in *; do
              if [ -d "$skill" ]; then
                echo "Validating skill: $skill"
                skills-ref validate "$skill"
              fi
            done
            touch $out
          '';
        };
      };
    };
}
