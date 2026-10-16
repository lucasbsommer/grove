#!/usr/bin/env bash
# Pull the latest Grove frontend from origin onto this server.
#
# The page is served directly from this checkout, so a fast-forward is all
# that's needed. The /api backend is a separate process and is NOT touched.
#
# Env:
#   GROVE_BRANCH     branch to track (default: main)
#   GROVE_RELOAD_CMD optional command to run only when new commits arrived
#                    (e.g. "systemctl --user restart grove") — usually unneeded
#                    for a static page.
set -euo pipefail
cd "$(dirname "$0")"

BRANCH="${GROVE_BRANCH:-main}"

git fetch --quiet origin "$BRANCH"
before="$(git rev-parse HEAD)"
git reset --hard "origin/$BRANCH"
after="$(git rev-parse HEAD)"

if [ "$before" != "$after" ]; then
  echo "[grove] $(date -Is) updated ${before:0:8} -> ${after:0:8}"
  if [ -n "${GROVE_RELOAD_CMD:-}" ]; then
    echo "[grove] reload: $GROVE_RELOAD_CMD"
    bash -c "$GROVE_RELOAD_CMD"
  fi
else
  echo "[grove] $(date -Is) already up to date (${after:0:8})"
fi
