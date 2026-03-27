---
name: preferred-tools
description: Preferred tools for common tasks like linting and link checking.
---

# Preferred Tools

To maintain consistency across the project, the following tools are preferred for common maintenance tasks:

- **Markdown Validation**: Use `markdownlint-cli2` for validating Markdown syntax.
- **Link Checking**: Use `lychee` for detecting broken internal and external links. It supports caching results to improve performance.
- **Pre-commit Hooks**: Use the `pre-commit` framework via `.pre-commit-config.yaml` to run validations before each commit.

Whenever possible, these tools should be invoked through Nix flakes (`nix flake check`).
