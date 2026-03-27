---
name: nix
description: Use Nix Flakes and flake-parts for software package management.
---

# Nix

Always use [Nix Flakes](https://nixos.wiki/wiki/Flakes) for any software packages required by the project. This ensures reproducible development environments and standardized tool versions across different systems.

Specifically, use [flake-parts](https://flake.parts/) to structure the `flake.nix` file. It provides a modular way to define the flake's output and helps in keeping the configuration clean and maintainable.

Do not use OS-specific package managers like DNF, APT, or others to install project dependencies. Instead, add them to the `devShells.default` and `checks` sections of the flake.
