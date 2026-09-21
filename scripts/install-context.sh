#!/usr/bin/env bash
# Land Cat Paw context in a Hermes home.
#
# SOUL.md is identity. On the Compose image, plow-init writes it every boot
# from the base persona plus /opt/hermes/plow-seed/persona.md (copied from
# PERSONA.md). This script does not touch that file in the container: the
# next boot would overwrite it.
# An existing Hermes (--home) has no plow-init, so a missing or stock
# SOUL.md is written from PERSONA.md. A soul someone already edited is left
# alone.
#
# AGENTS.md is project context. Hermes loads one project file, and a
# HERMES.md from Latch (when a Mac is connected) wins over AGENTS.md. The
# standing voice still lives in SOUL.md. This script never replaces an
# existing AGENTS.md. It appends the Cat Paw section, or refreshes that
# section if it is already there.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PERSONA="$ROOT/PERSONA.md"
SECTION="$ROOT/context/AGENTS.section.md"
COMPOSE=(docker compose -f "$ROOT/compose.yml")
SERVICE=hermes-cat-paw
HOME_DIR=""
BEGIN='<!-- cat-paw:agents -->'
END='<!-- /cat-paw:agents -->'

usage() {
  cat <<EOF
Usage: $(basename "$0") [--home HERMES_HOME]

  --home DIR  Write into this Hermes home (existing install).
              Default: the running Compose container.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --home)
      HOME_DIR="${2:-}"
      [[ -n "$HOME_DIR" ]] || { echo "install-context.sh: --home needs a directory." >&2; exit 1; }
      shift 2
      ;;
    --home=*)
      HOME_DIR="${1#*=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "install-context.sh: unexpected argument: $1" >&2
      exit 1
      ;;
  esac
done

[[ -f "$PERSONA" && -f "$SECTION" ]] || { echo "install-context.sh: missing PERSONA.md or context section." >&2; exit 1; }

# Print the marked section on stdout.
marked_section() {
  printf '%s\n' "$BEGIN"
  cat "$SECTION"
  if [[ -s "$SECTION" ]] && [[ "$(tail -c 1 "$SECTION" || true)" != $'\n' ]]; then
    printf '\n'
  fi
  printf '%s\n' "$END"
}

# Rewrite $1 so the Cat Paw section is present and current. The rest of the
# file is kept. A missing file is created as only that section.
apply_agents() {
  local file="$1"
  local tmp marked
  tmp="$(mktemp)"
  marked="$(mktemp)"
  marked_section >"$marked"
  if [[ ! -f "$file" ]]; then
    cat "$marked" >"$tmp"
  elif grep -F -q "$BEGIN" "$file"; then
    awk -v begin="$BEGIN" -v end="$END" -v ins="$marked" '
      $0 == begin {
        while ((getline line < ins) > 0) print line
        close(ins)
        skip = 1
        next
      }
      skip && $0 == end { skip = 0; next }
      !skip { print }
    ' "$file" >"$tmp"
  else
    cat "$file" >"$tmp"
    # A file with no trailing newline would glue the heading to the last line.
    [[ ! -s "$file" || "$(tail -c 1 "$file" || true)" == $'\n' ]] || printf '\n' >>"$tmp"
    printf '\n' >>"$tmp"
    cat "$marked" >>"$tmp"
  fi
  mv "$tmp" "$file"
  rm -f "$marked"
}

is_stock_soul() {
  local file="$1" text
  text="$(tr -d '\r' <"$file" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  [[ -z "$text" ]] && return 0
  case "$text" in
    "You are Hermes Agent, built by Nous Research."*) return 0 ;;
    "You are Hermes Agent, an intelligent AI assistant created by Nous Research."*) return 0 ;;
    "# Hermes Agent Persona"*) return 0 ;;
  esac
  return 1
}

# --home only. Compose SOUL.md is composed at boot.
apply_soul() {
  local file="$1"
  if [[ -f "$file" ]] && ! is_stock_soul "$file"; then
    if grep -F -q '# Cat Paw' "$file" && grep -F -q 'chaotic builder cat' "$file"; then
      cp "$PERSONA" "$file"
      echo "install-context.sh: refreshed SOUL.md"
      return
    fi
    echo "install-context.sh: leaving existing SOUL.md"
    return
  fi
  cp "$PERSONA" "$file"
  echo "install-context.sh: wrote SOUL.md"
}

if [[ -n "$HOME_DIR" ]]; then
  mkdir -p "$HOME_DIR"
  apply_soul "$HOME_DIR/SOUL.md"
  apply_agents "$HOME_DIR/AGENTS.md"
  echo "install-context.sh: AGENTS.md section is in $HOME_DIR"
  exit 0
fi

if [[ -z "$("${COMPOSE[@]}" ps -q "$SERVICE" 2>/dev/null || true)" ]]; then
  echo "install-context.sh: Compose agent is not running." >&2
  echo "Start it with scripts/install.sh, or pass --home HERMES_HOME." >&2
  exit 1
fi

stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
if "${COMPOSE[@]}" exec -T -u 0 "$SERVICE" sh -c 'test -f /var/lib/hermes/AGENTS.md'; then
  "${COMPOSE[@]}" exec -T -u 0 "$SERVICE" cat /var/lib/hermes/AGENTS.md >"$stage/AGENTS.md"
fi
apply_agents "$stage/AGENTS.md"
tar -C "$stage" -cf - AGENTS.md | "${COMPOSE[@]}" exec -T -u 0 "$SERVICE" tar -C /var/lib/hermes -xf -
"${COMPOSE[@]}" exec -T -u 0 "$SERVICE" chmod 0644 /var/lib/hermes/AGENTS.md
echo "install-context.sh: appended the Cat Paw section to AGENTS.md"
echo "install-context.sh: SOUL.md is PERSONA.md, composed on boot after the base persona"
