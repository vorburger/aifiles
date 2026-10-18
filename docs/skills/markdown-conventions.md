# Markdown Conventions

> Conventions for Markdown files in this repository.

- Whenever possible, use relative instead of absolute links to `*.md` Markdown files within the same Git repository.

- Directory paths in Markdown files should be formatted as clickable relative file links, e.g., `[dir](path/to/dir/)`.
  Link texts ("dir", here) should be surrounded by single backticks (so `dir`).

- Do NOT use horizontal rules (`---` or `<hr>`) to separate headings or sections. Modern typography relies on semantic heading hierarchy (`#`, `##`, `###`) and whitespace / vertical rhythm to structure content. Horizontal rules clutter the layout, break the reading flow, and look dated. Reserve `---` solely for YAML frontmatter delimiters when required.
