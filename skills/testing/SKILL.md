---
name: testing
description: Guidelines for determining how to test a project based on its contents.
---

# Testing Projects

When asked to "test" a project, you must first inspect the repository to determine what testing frameworks or build tools it uses. The correct command depends heavily on the files present in the root directory.

Use the following rules to figure out the correct test command(s). Note that some projects can be "polyglot" (e.g. they contain a Java backend and a TypeScript frontend, or they use Nix), so you may need to run multiple of these.

## Nix

If the project contains a `./flake.nix` at its root:

- Run `nix flake check`

## Java - Maven

If the project contains a `pom.xml`:

- Run `mvn test`

## Java/Kotlin - Gradle

If the project smells of Gradle (contains `build.gradle`, `build.gradle.kts`, `settings.gradle`, or `gradlew`):

- Run `gradle check` (or `./gradlew check` if the wrapper is present)

## JavaScript/TypeScript

If the project contains a `package.json`, you need to figure out whether to use `npm`, `bun`, or another package manager based on the lockfile present:

- If `bun.lockb` or `bun.lock` is present: run `bun install && bun test`
- If `package-lock.json` is present: run `npm install && npm test`
- If `yarn.lock` is present: run `yarn install && yarn test`
- If `pnpm-lock.yaml` is present: run `pnpm install && pnpm test`
- If no lockfile is present, default to `npm install && npm test` (or ask the user).
