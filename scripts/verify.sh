#!/usr/bin/env bash
# Confirm the Compose agent is the Index identity hermes-cat-paw and that the
# reporter can write its ledger. Always exec the Index client as uid hermes:
# `docker compose exec` defaults to root, and a root-owned ledger on the sticky
# HERMES_HOME cannot be updated by the 5-minute reporter.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE=(docker compose -f "$ROOT/compose.yml")
SERVICE=hermes-cat-paw
PYTHON=/opt/hermes/.venv/bin/python3
CLIENT=/opt/plow/agent-index-client.py

cd "$ROOT"

if [[ -z "$("${COMPOSE[@]}" ps -q "$SERVICE" 2>/dev/null)" ]]; then
  echo "verify: container is not running. Start it with scripts/install.sh." >&2
  exit 1
fi

echo "verify: repairing Index ledger ownership (sticky HERMES_HOME)"
# Single quotes are deliberate: this payload expands inside the container.
# shellcheck disable=SC2016
"${COMPOSE[@]}" exec -T -u 0 "$SERVICE" sh -c '
  for f in /var/lib/hermes/.agent-index-state.json \
           /var/lib/hermes/.agent-index-state.json.new \
           /var/lib/hermes/.agent-index.json \
           /var/lib/hermes/.agent-index.lock; do
    [ -e "$f" ] || continue
    chown hermes:hermes "$f"
  done
  idf=/run/s6/container_environment/AGENT_ID
  if [ -r "$idf" ]; then
    got=$(cat "$idf")
    echo "verify: container AGENT_ID=$got"
    [ "$got" = "hermes-cat-paw" ] || {
      echo "verify: AGENT_ID must be hermes-cat-paw" >&2
      exit 1
    }
  fi
'

echo "verify: waiting for Hermes state.db"
n=0
while ! "${COMPOSE[@]}" exec -T -u hermes "$SERVICE" sh -c "test -s /var/lib/hermes/state.db"; do
  n=$((n + 1))
  if [ "$n" -gt 60 ]; then
    echo "verify: state.db did not appear" >&2
    exit 1
  fi
  sleep 2
done

exec_hermes() {
  "${COMPOSE[@]}" exec -T -u hermes \
    -e HOME=/var/lib/hermes \
    -e HERMES_HOME=/var/lib/hermes \
    -e AGENT_ID=hermes-cat-paw \
    "$SERVICE" "$PYTHON" "$CLIENT" "$@"
}

register_page() {
  local token
  token="$("${COMPOSE[@]}" exec -T -u 0 "$SERVICE" sh -c 'cat /run/s6/container_environment/PLOW_AGENT_TOKEN')"
  "${COMPOSE[@]}" exec -T -u hermes \
    -e HOME=/var/lib/hermes \
    -e HERMES_HOME=/var/lib/hermes \
    -e AGENT_ID=hermes-cat-paw \
    -e PLOW_AGENT_TOKEN="$token" \
    "$SERVICE" "$PYTHON" "$CLIENT" \
    --register --agent hermes-cat-paw \
    --name "Hermes Cat Paw" \
    --blurb "Authorized recon from your phone. Latch approves every command and browser session on the computer you own." \
    --runtime "Hermes / Plow Latch" \
    --repo "https://github.com/kumanaya/hermes-cat-paw" \
    --install-url "https://github.com/kumanaya/hermes-cat-paw/blob/main/docs/INSTALL.md" \
    --video "KjWFtHh0EFE" \
    --image "https://raw.githubusercontent.com/kumanaya/hermes-cat-paw/main/hackathon-banner.png" \
    --image "https://raw.githubusercontent.com/kumanaya/hermes-cat-paw/main/docs/images/cybersecurity.png" \
    --image "https://raw.githubusercontent.com/kumanaya/hermes-cat-paw/main/docs/images/real-usage.png"
}

echo "verify: Index client as uid hermes (never root)"
echo "verify: --self-check uses throwaway /tmp dirs; 'unreadable' there is expected."
echo "verify: 'agentsview not installed' is optional in this image. Hermes state.db is what counts."
exec_hermes --self-check
status=0
exec_hermes status || status=$?
echo "verify: status exit $status (0=registered, 3=unregistered)"
if [ "$status" -eq 3 ]; then
  echo "verify: not registered yet — registering now (do not wait for the 5-minute loop)"
  if register_page; then
    status=0
    exec_hermes status || status=$?
  fi
fi
if [ "$status" -ne 0 ] && [ "$status" -ne 3 ]; then
  echo "verify: Index status failed ($status)" >&2
  exit 1
fi
exec_hermes --agent hermes-cat-paw --dry-run

echo "verify: reporting current usage as hermes"
if ! exec_hermes --agent hermes-cat-paw; then
  echo "verify: live report failed. Check docker compose logs hermes-cat-paw" >&2
  exit 1
fi

read_chat() {
  "${COMPOSE[@]}" exec -T -u hermes "$SERVICE" "$PYTHON" -c '
import json, sys
try:
    g = json.load(open("/var/lib/hermes/gateway_state.json"))
except FileNotFoundError:
    print("missing")
    sys.exit(0)
p = (g.get("platforms") or {}).get("plow_chat") or {}
print(p.get("state") or "unknown")
'
}

echo "verify: waiting for Plow Chat"
n=0
chat_state="$(read_chat)"
while [ "$chat_state" != "connected" ] && [ "$n" -lt 30 ]; do
  n=$((n + 1))
  sleep 2
  chat_state="$(read_chat)"
done
echo "verify: plow_chat=$chat_state"
if [ "$chat_state" != "connected" ]; then
  echo "verify: Plow Chat is not connected yet. Text the line after it comes online." >&2
fi

pack="$("${COMPOSE[@]}" exec -T -u hermes "$SERVICE" sh -c \
  'find /var/lib/hermes/skills/cybersecurity-skills -name SKILL.md -type f 2>/dev/null | wc -l' || true)"
pack="${pack//$'\r'/}"
pack="${pack#"${pack%%[![:space:]]*}"}"
echo "verify: cybersecurity-skills pack=${pack:-0} (run scripts/install-skills.sh if this is 0)"

echo "verify: baked review CLIs"
if ! "${COMPOSE[@]}" exec -T -u hermes "$SERVICE" /opt/cat-paw/verify-review-tools.sh; then
  echo "verify: review CLIs missing. Rebuild the image (scripts/install.sh)." >&2
  exit 1
fi

if [ "$status" -eq 0 ]; then
  echo "verify: container OK, usage heartbeat signed in."
  echo "verify: days=0 / tokens=0 is normal before a real Hermes chat."
else
  echo "verify: container OK, usage heartbeat not signed in yet. It retries on its own. This is not a failed install."
fi
echo "verify: do not docker compose exec the Index client as root; use this script or -u hermes."
# Name the line so the installing agent can relay it. Failure here is not a
# failed verify — the container may still be healthy.
if ! "$ROOT/scripts/announce-line.sh"; then
  echo "verify: could not name the line. Do not make the owner guess." >&2
fi
