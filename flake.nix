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

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            markdownlint-cli2
            lychee
            pre-commit
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
        };
      };
    };
}
