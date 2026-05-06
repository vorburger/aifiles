---
name: scripting
description: Conventions for writing and executing scripts (TS, Bash, etc.).
---

# Scripting Conventions

Always follow these conventions when writing or documenting scripts for this project:

## Execution

- **Shebang Usage**: Do NOT launch `*.ts` scripts by prefixing them with `bun` in documentation or commands if they have a shebang (`#!/usr/bin/env bun`). Rely on the shebang and execute the file directly.
- **Path Prefixing**: Do NOT use the `./` prefix when executing scripts from the root of the repository if the relative path (e.g., `scripts/my-script.ts`) is sufficient.
- **Executability**: Ensure scripts have the executable bit set (`chmod +x`).

## TypeScript Scripts

- Use `#!/usr/bin/env bun` as the shebang for TypeScript scripts intended to be run with Bun.
- Use the `.ts` extension to ensure proper tooling support (type-checking, formatting).
