# Agents

This repository uses Nix for dependency management and environment reproducibility.

## Nix Environment Setup

If the `nix` command is not available in the environment, you must run the installation script:

- [`skills/install-nix/scripts/install-nix.sh`](skills/install-nix/scripts/install-nix.sh)

## Non-Regression Testing

After making any changes to the codebase, always run the following command to ensure this Nix flake is still valid:

```bash
nix flake check
```
