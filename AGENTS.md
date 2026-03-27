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

## Agent Skills Validation

This project uses [Agent Skills](https://agentskills.io). All skills in the `skills/` directory are automatically validated during `nix flake check` using the `skills-ref` tool (fetched from `github:agentskills/agentskills`).

The `skills-ref` package is also available in the default `devShell` for manual validation:

```bash
nix develop
skills-ref validate skills/your-skill
```
