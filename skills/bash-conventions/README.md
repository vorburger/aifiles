# Bash Conventions

This directory contains the `bash-conventions` skill for the agent.

## Safe Settings Explanation

The `SKILL.md` file requires using `set -eux -o pipefail`. Here is what these options ensure:

- `-e`: The script exits if a command fails. This prevents cascading errors where a script continues running even though a prerequisite step failed.
- `-u`: Treat unset variables as an error and exit immediately. This helps catch typos in variable names.
- `-x`: Print commands and their arguments as they are executed. This is useful for debugging to see exactly what is being run.
- `-o pipefail`: The return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully. Without this, a pipeline might be considered successful even if an early command in it failed.
