{
  description = "Agentic AI Assistant working for https://www.vorburger.ch";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixfiles.url = "github:vorburger/nixfiles";
    agentskills-src = {
      url = "github:agentskills/agentskills";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, nixfiles, agentskills-src, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      imports = [
        inputs.nixfiles.flakeModules.lint
      ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages.skills-ref = pkgs.python311Packages.buildPythonApplication {
          pname = "skills-ref";
          version = "0.1.0";
          src = "${agentskills-src}/skills-ref";
          pyproject = true;
          build-system = with pkgs.python311Packages; [ hatchling ];
          dependencies = with pkgs.python311Packages; [ click strictyaml ];
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
            shellcheck
            self'.packages.skills-ref
          ];
          shellHook = ''
            pre-commit install
          '';
        };

        checks = {
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
