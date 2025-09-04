#!/usr/bin/env bash
# update_exclusions.sh
#
# MIT License
# Copyright (c) 2025 Romathi

set -euo pipefail

CONFIG_FILE=".pre-commit-config.yaml"
DEFAULT_EXCLUSIONS_FILE=".pre-commit-default-exclusions"
CUSTOM_EXCLUSIONS_FILE=".pre-commit-exclusions"
TMP_FILE=$(mktemp)

if ! grep -q '# Start exclude' "$CONFIG_FILE" || ! grep -q '# End exclude' "$CONFIG_FILE"; then
    echo "❌  ERROR: Markers '# Start exclude' and/or '# End exclude' not found in $CONFIG_FILE."
    echo "Please add these lines around the exclude block before running this script."
    exit 1
fi

# Read default exclusions (mandatory)
default_exclusions=$(< "$DEFAULT_EXCLUSIONS_FILE")

# Read custom exclusions (optional)
if [[ -f "$CUSTOM_EXCLUSIONS_FILE" && -s "$CUSTOM_EXCLUSIONS_FILE" ]]; then
    custom_exclusions=$(< "$CUSTOM_EXCLUSIONS_FILE")
    default_exclusions="${default_exclusions}|"
    new=$(printf '%s\n%s' "$default_exclusions" "$custom_exclusions")
else
    new="$default_exclusions"
fi

# Prepare the new exclusion block
new=$(printf '%s\n' "$default_exclusions" "$custom_exclusions" | sed 's/^/  /')

# Feed awk directly with the block via a file descriptor
awk -v block_file=<(echo "$new") '
    BEGIN {
        inside = 0
        while ((getline line < block_file) > 0) {
            block = block line "\n"
        }
        close(block_file)
    }
    /# Start exclude/ {
        print; print "exclude: |"
        printf "%s", block
        inside = 1
        next
    }
    /# End exclude/ { inside = 0 }
    !inside
' "$CONFIG_FILE" > "$TMP_FILE"


if ! cmp -s "$TMP_FILE" "$CONFIG_FILE"; then
    mv "$TMP_FILE" "$CONFIG_FILE"
    echo "✅  Updated .pre-commit-config.yaml with new exclusions."
    echo "⚠️ Exclusion list changed. Rerun pre-commit to apply changes."
    exit 99
else
    rm "$TMP_FILE"
    echo "✅  Exclusions are already up to date. No changes made."
    exit 0
fi
