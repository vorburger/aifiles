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
This ensures:
- `-e`: The script exits if a command fails.
- `-u`: Treat unset variables as an error and exit immediately.
- `-x`: Print commands and their arguments as they are executed.
- `-o pipefail`: The return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully.
