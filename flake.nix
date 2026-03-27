{
  description = "Agentic AI Assistant working for https://www.vorburger.ch";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    agentskills-src = {
      url = "github:agentskills/agentskills";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, agentskills-src, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages.skills-ref = pkgs.python311Packages.buildPythonApplication {
          pname = "skills-ref";
          version = "0.1.0";
          src = "${agentskills-src}/skills-ref";
          pyproject = true;
          build-system = with pkgs.python311Packages; [ hatchling ];
          dependencies = with pkgs.python311Packages; [ click strictyaml ];
        };

        # Nix sandbox has no network access; this wrapper checks local links only.
        packages.lychee-offline = pkgs.writeShellScriptBin "lychee-offline" ''
          exec ${pkgs.lychee}/bin/lychee --offline "$@"
        '';

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
            shellcheck
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

          shellcheck = pkgs.runCommand "shellcheck" {
            buildInputs = [ pkgs.shellcheck ];
          } ''
            cd ${self}
            find . -name "*.sh" -not -path "./.direnv/*" -exec shellcheck {} +
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
            cd ${self}
            for skill in skills/*/; do
              if [ -d "$skill" ]; then
                echo "Validating $skill"
                skills-ref validate "$skill" || exit 1
              fi
            done
            touch $out
          '';
        };
      };
    };
}
