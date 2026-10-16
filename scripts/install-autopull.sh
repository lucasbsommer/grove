#!/usr/bin/env bash
# Install a cron job on THIS server that runs deploy.sh on an interval, so the
# box auto-pulls new commits from origin/main. Run once on the server.
#
# Usage: ./scripts/install-autopull.sh [INTERVAL_MINUTES]   (default: 2)
#   Uninstall: ./scripts/install-autopull.sh --remove
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MARKER="# grove-autopull"

if [ "${1:-}" = "--remove" ]; then
  ( crontab -l 2>/dev/null | grep -vF "$MARKER" ) | crontab - || true
  echo "Removed grove auto-pull cron."
  exit 0
fi

INTERVAL_MIN="${1:-2}"
CRON_LINE="*/${INTERVAL_MIN} * * * * cd $REPO_DIR && ./deploy.sh >> $REPO_DIR/.deploy.log 2>&1 $MARKER"

( crontab -l 2>/dev/null | grep -vF "$MARKER"; echo "$CRON_LINE" ) | crontab -

echo "Installed grove auto-pull (every ${INTERVAL_MIN} min):"
echo "  $CRON_LINE"
echo "Log: $REPO_DIR/.deploy.log"
