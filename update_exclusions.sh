#!/usr/bin/env bash
# update_exclusions.sh
#
# MIT License
# Copyright (c) 2025 Romathi

set -e

# Read your default and custom exclusions files (assumed in repo root or repo working dir)
default_exclusions=$(cat .pre-commit-default-exclusions)
custom_exclusions=$(cat .pre-commit-exclusions)

if [[ -s .pre-commit-exclusions ]]; then
    default_exclusions="${default_exclusions}|"
fi

new_exclusions=$(printf '%s\n%s' "$default_exclusions" "$custom_exclusions")

# Update the exclude block in .pre-commit-config.yaml (in current repo root)
awk -v excl="$new_exclusions" '
  BEGIN { inside=0 }
  /^exclude: \|/ { print; inside=1; next }
  inside && /^# End exclusion/ { print excl; print; inside=0; next }
  inside { next }
  { print }
' .pre-commit-config.yaml > .pre-commit-config.yaml.tmp && mv .pre-commit-config.yaml.tmp .pre-commit-config.yaml

echo "✅ Updated .pre-commit-config.yaml with new exclusions."
