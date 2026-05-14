---
name: git-workflow
description: Guidelines for Michael Vorburger's preferred Git workflow.
---

# Git Workflow

This skill describes Michael Vorburger's preferred Git workflow across his projects:

## Pre-Commit Testing

- Before creating a commit, always ensure the project passes its tests.
- Refer to the `testing` skill to determine how to run tests for the current repository.

## Automagic Push

- After successfully completing a `git commit`, always automatically run `git push` to push the changes to the remote repository.
