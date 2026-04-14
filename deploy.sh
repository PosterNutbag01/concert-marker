#!/usr/bin/env bash
# One-shot deploy: stage everything, commit, push to main.
# GitHub Pages rebuilds automatically.
#
# Usage:
#   ./deploy.sh                 # prompts for commit message
#   ./deploy.sh "my message"    # uses the given message
#   ./deploy.sh -m "my message" # same
set -euo pipefail

cd "$(dirname "$0")"

# Must be inside a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "error: not a git repository" >&2
  exit 1
fi

# Bail early if nothing changed
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  echo "Nothing to deploy — working tree clean."
  exit 0
fi

# Pick up a message from args, or prompt
msg="${1:-}"
if [ "$msg" = "-m" ] && [ $# -ge 2 ]; then
  msg="$2"
fi
if [ -z "$msg" ]; then
  printf "Commit message: "
  read -r msg
fi
if [ -z "$msg" ]; then
  msg="Update site"
fi

echo "→ Staging changes…"
git add -A

echo "→ Committing: $msg"
git commit -m "$msg"

echo "→ Pushing to origin/main…"
git push origin main

echo ""
echo "✓ Deployed. GitHub Pages will rebuild in ~30-60s."
echo "  Live:  https://posternutbag01.github.io/concert-marker/"
echo "  Repo:  https://github.com/PosterNutbag01/concert-marker"
