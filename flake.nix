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

          lychee-offline = pkgs.runCommand "lychee-offline" {
            buildInputs = [ pkgs.lychee ];
          } ''
            cd ${self}
            lychee --offline .
            touch $out
          '';

          # Optional online check, not enabled by default in 'nix flake check'
          # if we want to keep CI fast/stable, but here it is for manual use.
          lychee-online = pkgs.runCommand "lychee-online" {
            buildInputs = [ pkgs.lychee ];
          } ''
            cd ${self}
            lychee .
            touch $out
          '';
        };
      };
    };
}
