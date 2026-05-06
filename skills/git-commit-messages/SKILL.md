---
name: git-commit-messages
description: Guidelines for Michael Vorburger's personal Git commit style.
---

# Git Commit Messages

This skill describes Michael Vorburger's preferred style for Git commit messages across his projects:

## Conventional Commits

Use Conventional Commits format where applicable: `<type>(<scope>): <description>`

Common types:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `build`: Changes that affect the build system or external dependencies
- `ci`: Changes to our CI configuration files and scripts
- `chore`: Other changes that don't modify src or test files

## Skills as Code

In this project, "skills" (files under a directory named `skills/` containing `name:` and `description:` YAML front-matter in their MD) are considered executable code for the agent, not just documentation.
- Adding or modifying a skill should be commit type `feat` or `fix`, not `docs`.

## General Guidelines

- Keep the subject line short (typically under 50 characters).
- Use the imperative mood in the subject line (e.g., "Add feature" instead of "Added feature").
- Use the body to explain what and why, vs. how.
