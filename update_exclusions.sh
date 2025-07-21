#!/usr/bin/env bash
# update_exclusions.sh
#
# MIT License
# Copyright (c) 2025 Romathi

set -e

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
  /# Start exclusion/ {
    print; print "exclude: |"
    print new_block
    inside = 1
    next
  }
  /# End exclusion/ {
    inside = 0
  }
  !inside
' .pre-commit-config.yaml 2>/dev/null > .pre-commit-config.yaml.tmp && mv .pre-commit-config.yaml.tmp .pre-commit-config.yaml

echo "✅ Updated .pre-commit-config.yaml with new exclusions."
