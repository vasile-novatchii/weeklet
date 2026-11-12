#!/usr/bin/env bash
# Generates markdown release notes from conventional-commit subjects.
# Usage: scripts/changelog.sh <tag> [repo-slug]
# Range: previous vX.Y.Z tag (or the whole history) .. <tag>
set -euo pipefail

TAG="${1:?usage: changelog.sh <tag> [owner/repo]}"
REPO="${2:-}"

PREV=$(git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' "$TAG^" 2>/dev/null || true)
RANGE="${PREV:+$PREV..}$TAG"

subjects=$(git log "$RANGE" --no-merges --pretty=format:'%s')

section() { # title, regex of conventional types
  local title="$1" types="$2" lines
  lines=$(printf '%s\n' "$subjects" | grep -E "^($types)(\([^)]*\))?!?: " || true)
  [ -z "$lines" ] && return 0
  printf '### %s\n\n' "$title"
  printf '%s\n' "$lines" \
    | sed -E 's/^[a-z]+\(([^)]*)\)!?: /- **\1:** /; s/^[a-z]+!?: /- /'
  printf '\n'
}

printf '## What'"'"'s changed in %s\n\n' "$TAG"
section 'Features' 'feat'
section 'Bug fixes' 'fix'
section 'Performance' 'perf'
section 'Refactoring' 'refactor'
section 'Documentation' 'docs'
section 'Tests' 'test'
section 'CI and build' 'ci|build'
section 'Chores' 'chore|style'

other=$(printf '%s\n' "$subjects" | grep -vE '^(feat|fix|perf|refactor|docs|test|ci|build|chore|style)(\([^)]*\))?!?: ' || true)
if [ -n "$other" ]; then
  printf '### Other\n\n'
  printf '%s\n' "$other" | sed 's/^/- /'
  printf '\n'
fi

if [ -n "$REPO" ] && [ -n "$PREV" ]; then
  printf '**Full changelog:** https://github.com/%s/compare/%s...%s\n' "$REPO" "$PREV" "$TAG"
fi
