---
name: git-commit-messages
description: Guidelines for Michael Vorburger's personal Git commit style.
---

# Git Commit Messages

This skill describes Michael Vorburger's preferred style for Git commit messages across his projects:

## Conventional Commits

Use Conventional Commits format where applicable: `<type>(<scope>): <description>`

Common types:
- `feat`: If it looks like any sort of new feature is introduced, even minor.
- `fix`: If it's clearly more of a sort of minor fix.
- `docs`: If only files in the `docs/` directory changed, and no files outside of it.
- `deps`: If only dependency related files changed (e.g., `MODULE.bazel`, `docs/dev/dependencies.txt`, `maven_install.json`).
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc).
- `refactor`: A code change that neither fixes a bug nor adds a feature.
- `perf`: A code change that improves performance.
- `test`: Adding missing tests or correcting existing tests.
- `build`: Changes that affect the build system or external dependencies.
- `ci`: Changes to our CI configuration files and scripts.
- `chore`: Other changes that don't modify src or test files.

## Skills as Code

Files under a directory named `skills/` containing `name:` and `description:` YAML front-matter in their MD are considered executable code for the agent, not just documentation. Adding or modifying a skill should therefore always be of commit type `feat` or `fix`, not `docs`.

## General Guidelines

- Keep the subject line (TL;DR) short (maximum 60 characters).
- Use the imperative mood in the subject line (e.g., "Add feature" instead of "Added feature").
- Use the body to explain what and why, vs. how.
- Do not end the subject line with a dot.
