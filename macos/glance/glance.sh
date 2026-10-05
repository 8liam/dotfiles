#!/bin/sh
# Glance in an Apple container (https://github.com/apple/container).
# Idempotent — safe to run by hand and from the login LaunchAgent.
#
#   glance.sh [up]    create the container if missing, start it if stopped
#   glance.sh restart restart it (Glance only reads glance.yml on startup)
#
# Needs: Apple silicon, macOS 26+, `brew install container`.
set -eu

NAME=glance
IMAGE=docker.io/glanceapp/glance
CONFIG_DIR="$HOME/glance/config"
PORT="${GLANCE_PORT:-8080}"

command -v container >/dev/null 2>&1 || { echo "Apple container not found — brew install container" >&2; exit 1; }
[ -f "$CONFIG_DIR/glance.yml" ] || { echo "missing $CONFIG_DIR/glance.yml" >&2; exit 1; }

running() { container ls | awk -v n="$NAME" 'NR > 1 && $1 == n { found = 1 } END { exit !found }'; }

# The runtime's service has to be up before any container command works.
if ! container system status 2>/dev/null | grep -q 'status *running'; then
  container system start --enable-kernel-install
fi

case "${1:-up}" in
  up)
    if running; then
      echo "$NAME already running"
    elif container inspect "$NAME" >/dev/null 2>&1; then
      container start "$NAME"
    else
      container run -d --name "$NAME" -p "$PORT:8080" -v "$CONFIG_DIR:/app/config" "$IMAGE"
    fi
    ;;
  restart)
    if running; then container stop "$NAME"; fi
    container start "$NAME"
    ;;
  *)
    echo "usage: glance.sh [up|restart]" >&2
    exit 2
    ;;
esac
