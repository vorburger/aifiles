# Gmail Pull

The `gmail-pull` script allows you to pull emails from Gmail based on a search filter and store them locally as YAML files, including attachments and body content.

## Usage

```bash
./scripts/gmail-pull "<gmail-filter>" <base_directory>
```

### Arguments

1.  **`<gmail-filter>`**: A Gmail search query (e.g., `"in:inbox is:important"`, `"from:google"`, `"label:project-x"`).
2.  **`<base_directory>`**: The directory where the emails and index will be stored.

### Examples

```bash
./scripts/gmail-pull "from:github" ./data/github-emails
```

## Output Structure

The script creates the following structure in the base directory:

-   **`index.yaml`**: A mapping of search filters to the list of message IDs found.
-   **`messages/`**:
    -   `<message-id>.yaml`: The full Gmail message resource in YAML format.
    -   `<message-id>.txt`: The plain text body of the email (if available).
    -   `<message-id>.html`: The HTML body of the email (if available).
    -   `<message-id>.md`: A basic Markdown version of the HTML body.
-   **`attachments/`**:
    -   `<message-id>/`:
        -   `<part-id>-<filename>`: The decoded attachment file.

## Features

-   **Parallel Downloads**: Downloads multiple messages concurrently for speed.
-   **Idempotent**: Skips messages that have already been downloaded (based on the presence of the `.yaml` file).
-   **Deterministic**: Message IDs in `index.yaml` are sorted to maintain a consistent file structure.
-   **Safe Attachment Naming**: Uses both `partId` and `filename` to avoid conflicts within a single email.

## Dependencies

-   **[gws](https://github.com/googleworkspace/cli)**: Google Workspace CLI, must be configured on the system.
-   **[yq](https://github.com/mikefarah/yq)**: YAML processor.
-   **[bun](https://bun.sh)**: Fast JavaScript runtime (used to run the script).
