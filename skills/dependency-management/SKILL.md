---
name: dependency-management
description: Procedures and requirements for adding new external dependencies.
---

# Dependency Management

When adding any new external dependencies to the project — whether Maven/Gradle dependencies or plugins, or NPM/Bun packages — you MUST:

1. Find and visit the originating Git repository for the project
2. Check the maintenance status:
   - Last commit date (should be recent, ideally within the last 6 months)
   - Issue response time and activity
   - Number of open issues and PRs
3. **Find and use the latest available version** of the dependency:
   - Check Maven Central, npm registry, or the GitHub releases page for the newest release
   - Always prefer recent versions over older ones (unless there's a specific reason to pin to an older version)
4. If the project appears abandoned or minimally maintained:
   - **DO NOT** add it without explicit approval
   - Inform the user about the maintenance concerns
   - Search for and suggest a more actively maintained alternative

This prevents the project from accumulating stale, unmaintained dependencies that could become security risks or cause compatibility issues, and keeps us on recent stable versions with bug fixes and security patches.
