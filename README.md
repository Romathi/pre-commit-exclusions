# Pre-commit Exclusions Updater

A simple script and pre-commit hook to automatically update the `exclude` regex patterns
in your `.pre-commit-config.yaml`. This tool helps maintain clean and consistent exclusions
across multiple repositories by merging default exclusions with custom rules.

---

## Features

- Reads default exclusions and appends custom exclusions from a separate file.
- Updates the `exclude:` block in `.pre-commit-config.yaml` safely.
- Can be used as a standalone script or integrated as a pre-commit hook.
- Designed to be reused across hundreds of repositories.

---

## Usage

Before using the script or hook, ensure your `.pre-commit-config.yaml` file contains the 
`exclude:` block delimited by these two comment lines exactly as shown:

```yaml
# Start exclude
exclude: |
# End exclude
```

This allows the script to correctly locate and replace the exclusion patterns.

### Standalone

Place your default exclusions in `.pre-commit-default-exclusions` and
your custom exclusions in `.pre-commit-exclusions`.

Run the update script:

```bash
./update_exclusions.sh
```

### As a pre-commit hook

Add the following to your `.pre-commit-config.yaml`:

```yaml
- repo: https://github.com/Romathi/pre-commit-exclusions
  rev: v0.1.1
  hooks:
    - id: update-exclusions
```
