---
name: preferred-tools
description: Preferred tools for common tasks like linting and link checking.
---

# Preferred Tools

To maintain consistency across the project, the following tools are preferred for common maintenance tasks:

- **Markdown Validation**: Use `markdownlint-cli2` for validating Markdown syntax.
- **Link Checking**: Use `lychee` for detecting broken internal and external links. It supports caching results to improve performance.
- **Git Hooks**: Use the `lefthook` framework via `lefthook.yaml` to run validations (like `prettier`, `markdownlint`, `shellcheck`, etc.) before each commit and push.
- **Formatting**: Use `prettier` for formatting Markdown, JSON, YAML, and TypeScript files. This is automatically managed via `lefthook` on staged files.

Whenever possible, these tools should be invoked through Nix flakes (`nix flake check`).
