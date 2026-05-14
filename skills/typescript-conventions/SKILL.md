---
name: typescript-conventions
description: Enforces TypeScript and project-specific coding standards, including Bun usage and the zero-warning policy. Use this skill when creating or modifying any TypeScript or configuration files.
---

# TypeScript & Code Conventions

This document outlines the coding standards and conventions used in Michael's TypeScript projects.

## Bun over NPM

In Michael's TypeScript projects, we exclusively use **Bun** for all package management and script execution. **NEVER** use `npm` or `yarn` commands unless explicitly required by an external tool.

- Install dependencies: `bun add <package>`
- Run scripts: `bun run <script>`
- Execute one-off tools: `bun x <command>`

## Philosophy on Warnings

We follow a strict **Zero Warning Policy**. Warnings that do not fail the build are generally ignored and therefore useless.

All automated tools (TypeScript compiler, linting, etc.) **MUST** be configured to fail the build if any warning is detected. Problems should either be fixed properly or, if absolutely necessary, suppressed with an explicit reason; they should never be left as "just warnings".

## Validation

After making any changes, you **MUST** validate the project using the available tooling, typically:

1. **Type Checking**: Run `bun x tsc --noEmit` to ensure TypeScript types are correct.
2. **Standard Checks**: Run `nix flake check` or `bun run check` (whichever is available in the specific project).
3. **Testing**: Run tests based on the `testing` skill guidelines.
4. **Hooks**: You can also run `lefthook run pre-commit` if applicable.
