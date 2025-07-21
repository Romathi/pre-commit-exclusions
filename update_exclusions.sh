#!/usr/bin/env bash
# update_exclusions.sh
#
# MIT License
# Copyright (c) 2025 Romathi

set -e

CONFIG_FILE=".pre-commit-config.yaml"

if ! grep -q '# Start exclude' "$CONFIG_FILE" || ! grep -q '# End exclude' "$CONFIG_FILE"; then
    echo "❌  ERROR: Markers '# Start exclude' and/or '# End exclude' not found in $CONFIG_FILE."
    echo "Please add these lines around the exclude block before running this script."
    exit 1
fi


# Read exclusions
default_exclusions=$(< .pre-commit-default-exclusions)
custom_exclusions=$(< .pre-commit-exclusions)

# Add '|' if needed
if [[ -s .pre-commit-exclusions ]]; then
    # Custom exclusions found.
    default_exclusions="${default_exclusions}|"
    new=$(printf '%s\n%s' "$default_exclusions" "$custom_exclusions")
else
    # No custom exclusions found.
    new="$default_exclusions"
fi

# Indent with two spaces
new=$(echo "$new" | sed 's/^/  /')

# Replace block in .pre-commit-config.yaml
awk -v new_block="$new" '
    BEGIN { inside = 0 }
    /# Start exclude/ {
        print; print "exclude: |"
        print new_block
        inside = 1
        next
    }
    /# End exclude/ {
        inside = 0
    }
    !inside
' .pre-commit-config.yaml 2>/dev/null > .pre-commit-config.yaml.tmp && mv .pre-commit-config.yaml.tmp .pre-commit-config.yaml

echo "✅  Updated .pre-commit-config.yaml with new exclusions."
echo "⚠️ Please rerun pre-commit (e.g. 'pre-commit run --all-files') to apply the new exclusions and avoid running hooks on excluded files."
