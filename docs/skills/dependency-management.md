# Dependency Management

> Procedures and requirements for adding new external dependencies.

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

## Handling Failing Dependency Update PRs

When automated dependency update PRs (e.g. from Dependabot or Renovate) fail due to upstream compatibility issues or ecosystem lag (for example, a new major language/compiler version not yet supported by linters or plugins):

1. **Investigate the Root Cause**: Determine if the failure is due to a temporary ecosystem incompatibility (such as an upstream tool waiting on a stable API or upcoming release).
2. **Find the Upstream Tracking Issue**: Search the relevant upstream project's issue tracker (e.g., GitHub Issues) to find the tracking issue or milestone for supporting the new version.
3. **Do NOT Hardcode Workarounds**: Avoid adding temporary ignores or exclusions to configuration files (e.g., `.github/dependabot.yaml` or `package.json` overrides) to suppress PRs, as this creates technical debt and obscures when upstream support arrives.
4. **Document on the PR**: Leave a comment linking the upstream tracking issue (e.g., `Pending <upstream-issue-url>`) so the PR status is clearly understood and can be merged or updated once the upstream fix lands.
