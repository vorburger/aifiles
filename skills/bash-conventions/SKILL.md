---
name: bash-conventions
description: Style and preferences for Bash scripts.
---

# Bash Conventions

Always follow these conventions when writing Bash scripts for this project:

## Shebang

Always start with a shebang pointing to `env bash`:

```bash
#!/usr/bin/env bash
```

## Safe Settings

Always use the following safe settings in one line near the top of the script:

```bash
set -eux -o pipefail
```
