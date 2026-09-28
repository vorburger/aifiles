{
  description = "Agentic AI Assistant working for https://www.vorburger.ch";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixfiles = {
      url = "github:vorburger/nixfiles";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    agentskills-src = {
      url = "github:agentskills/agentskills";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, nixfiles, agentskills-src, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        inputs.nixfiles.flakeModules.lint
      ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages.skills-ref = pkgs.python3Packages.buildPythonApplication {
          pname = "skills-ref";
          version = "0.1.0";
          src = "${agentskills-src}/skills-ref";
          pyproject = true;
          build-system = with pkgs.python3Packages; [ hatchling ];
          dependencies = with pkgs.python3Packages; [ click strictyaml ];
        };

        # Build the static website using https://zensical.org
        packages.website = pkgs.runCommand "aifiles-website" {
          buildInputs = [ pkgs.zensical ];
        } ''
          cp -r ${./docs} docs
          chmod -R u+w docs
          cp ${./zensical.toml} zensical.toml
          zensical build --clean
          cp -r site $out
        '';

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            bun
            yq-go
            markdownlint-cli2
            lychee
            lefthook
            prettier
            zensical
            shellcheck
            self'.packages.skills-ref
          ];
          shellHook = ''
            lefthook install > /dev/null 2>&1
            bun install > /dev/null 2>&1
          '';
        };

        checks = {
          website = self'.packages.website;

          skills-validate = pkgs.runCommand "skills-validate" {
            buildInputs = [ self'.packages.skills-ref ];
          } ''
            cd ${./skills}
            for skill in */; do
              if [ -d "$skill" ]; then
                echo "Validating skills/$skill"
                skills-ref validate "$skill" || exit 1
              fi
            done
            touch $out
          '';
        };
      };
    };
}
