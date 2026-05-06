# Agents

## Purpose

This repository, `aifiles`, is the central hub for global AI context, instructions, and skills applied across **all** of Michael Vorburger's repositories and projects. It serves a similar role to "dotfiles" but for LLMs and agents.

When working in this repository, keep in mind that skills here are intended to be globally applicable unless stated otherwise.

## Repository Structure

- `scripts/`: Executable TypeScript scripts (using `#!/usr/bin/env bun`).
- `skills/`: Global agent skills (following [Agent Skills](https://agentskills.io) conventions).
- `docs/`: Documentation for the `aifiles` system.
- `flake.nix`: Nix environment for development and CI.

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
