#!/usr/bin/env bash
# Clone the pinned extra skill packs into a Hermes home.
# Playbook text stays upstream. This script copies the pinned trees and the
# router skills from this repo. It does not relicense anything.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PIN="$ROOT/vendor/skill-packs.pin"
TOOLS="$ROOT/.tools/skill-packs"
COMPOSE=(docker compose -f "$ROOT/compose.yml")
SERVICE=hermes-cat-paw
HOME_DIR=""
LIST_ONLY=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [--home HERMES_HOME] [--list]

  --home DIR  Install into DIR/skills (existing Hermes).
              Default: the running Compose container.
  --list      Fetch each pin and print the pack id. Do not copy.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --home)
      HOME_DIR="${2:-}"
      [[ -n "$HOME_DIR" ]] || { echo "install-skill-packs.sh: --home needs a directory." >&2; exit 1; }
      shift 2
      ;;
    --home=*)
      HOME_DIR="${1#*=}"
      shift
      ;;
    --list)
      LIST_ONLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "install-skill-packs.sh: unexpected argument: $1" >&2
      exit 1
      ;;
  esac
done

declare -a ROUTERS=()
declare -a PACK_IDS=()

# Pack ids contain hyphens, which cannot sit in a shell variable name.
vid() { printf '%s' "${1//-/_}"; }

# shellcheck disable=SC2034
flush_pack() {
  [[ -n "${PACK_ID:-}" ]] || return 0
  local key
  key="$(vid "$PACK_ID")"
  PACK_IDS+=("$PACK_ID")
  printf -v "REPO_$key" '%s' "${PACK_REPO:-}"
  printf -v "SHA_$key" '%s' "${PACK_SHA:-}"
  printf -v "DEST_$key" '%s' "${PACK_DEST:-}"
  printf -v "LAYOUT_$key" '%s' "${PACK_LAYOUT:-flat}"
  printf -v "INCLUDE_$key" '%s' "${PACK_INCLUDE:-}"
  printf -v "EXCLUDE_$key" '%s' "${PACK_EXCLUDE:-}"
  printf -v "DOC_$key" '%s' "${PACK_DOC:-}"
  PACK_ID=""
  PACK_REPO=""
  PACK_SHA=""
  PACK_DEST=""
  PACK_LAYOUT="flat"
  PACK_INCLUDE=""
  PACK_EXCLUDE=""
  PACK_DOC=""
}

PACK_ID=""
PACK_REPO=""
PACK_SHA=""
PACK_DEST=""
PACK_LAYOUT="flat"
PACK_INCLUDE=""
PACK_EXCLUDE=""
PACK_DOC=""

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  [[ -z "$line" || "$line" == \#* ]] && continue
  key="${line%% *}"
  val="${line#* }"
  case "$key" in
    router) ROUTERS+=("$val") ;;
    pack)
      flush_pack
      PACK_ID="$val"
      ;;
    repo) PACK_REPO="$val" ;;
    sha) PACK_SHA="$val" ;;
    dest) PACK_DEST="$val" ;;
    layout) PACK_LAYOUT="$val" ;;
    include) PACK_INCLUDE+="${PACK_INCLUDE:+$'\n'}$val" ;;
    exclude) PACK_EXCLUDE+="${PACK_EXCLUDE:+$'\n'}$val" ;;
    doc) PACK_DOC+="${PACK_DOC:+$'\n'}$val" ;;
    *)
      echo "install-skill-packs.sh: unknown pin key: $key" >&2
      exit 1
      ;;
  esac
done < "$PIN"
flush_pack

sync_checkout() {
  local id="$1" repo="$2" sha="$3"
  local slug dir
  slug="${repo#https://github.com/}"
  slug="${slug%.git}"
  slug="${slug//\//__}"
  dir="$TOOLS/$slug"
  mkdir -p "$TOOLS"
  if [[ ! -d "$dir/.git" ]]; then
    echo "install-skill-packs.sh: cloning $id"
    git clone --depth 1 "$repo" "$dir"
  fi
  echo "install-skill-packs.sh: checking out $id $sha"
  git -C "$dir" fetch --depth 1 origin "$sha"
  git -C "$dir" checkout --detach "$sha"
  local got
  got="$(git -C "$dir" rev-parse HEAD)"
  if [[ "$got" != "$sha" ]]; then
    echo "install-skill-packs.sh: $id expected $sha, got $got" >&2
    exit 1
  fi
}

copy_skill_dir() {
  local src="$1" parent="$2" name="$3"
  rm -rf "$parent/$name"
  mkdir -p "$parent"
  cp -a "$src" "$parent/$name"
}

install_pack() {
  local id="$1" checkout="$2" skills_root="$3"
  local key repo sha dest layout includes excludes docs
  key="$(vid "$id")"
  repo="$(eval "printf '%s' \"\$REPO_$key\"")"
  sha="$(eval "printf '%s' \"\$SHA_$key\"")"
  dest="$(eval "printf '%s' \"\$DEST_$key\"")"
  layout="$(eval "printf '%s' \"\$LAYOUT_$key\"")"
  includes="$(eval "printf '%s' \"\$INCLUDE_$key\"")"
  excludes="$(eval "printf '%s' \"\$EXCLUDE_$key\"")"
  docs="$(eval "printf '%s' \"\$DOC_$key\"")"
  [[ -n "$repo" && -n "$sha" && -n "$dest" ]] || {
    echo "install-skill-packs.sh: incomplete pack $id" >&2
    exit 1
  }
  [[ "$layout" == "flat" || "$layout" == "grouped" ]] || {
    echo "install-skill-packs.sh: $id layout must be flat or grouped" >&2
    exit 1
  }
  local out="$skills_root/$dest"
  rm -rf "$out"
  mkdir -p "$out"

  local inc src parent child name kept
  while IFS= read -r inc; do
    [[ -n "$inc" ]] || continue
    src="$checkout/$inc"
    [[ -d "$src" ]] || { echo "install-skill-packs.sh: $id missing $inc" >&2; exit 1; }
    if [[ -f "$src/SKILL.md" ]]; then
      copy_skill_dir "$src" "$out" "$(basename "$src")"
      continue
    fi
    parent="$out"
    if [[ "$layout" == "grouped" ]]; then
      parent="$out/$(basename "$(dirname "$src")")"
    fi
    kept=0
    for child in "$src"/*; do
      [[ -e "$child" ]] || continue
      name="$(basename "$child")"
      if [[ -n "$excludes" ]] && printf '%s\n' "$excludes" | grep -qx "$name"; then
        continue
      fi
      target="$child"
      if [[ ! -f "$target/SKILL.md" ]]; then
        # Git symlink checked out as a text file (core.symlinks=false).
        [[ -f "$child" && ! -d "$child" ]] || continue
        link="$(tr -d '\r\n' < "$child")"
        case "$link" in
          *[!A-Za-z0-9_./-]*|"") continue ;;
        esac
        resolved="$(cd "$src" && cd "$link" 2>/dev/null && pwd)" || continue
        case "$resolved" in
          "$checkout"|"$checkout"/*) ;;
          *) continue ;;
        esac
        [[ -f "$resolved/SKILL.md" ]] || continue
        target="$resolved"
      fi
      copy_skill_dir "$target" "$parent" "$name"
      kept=$((kept + 1))
    done
    if [[ "$kept" -eq 0 ]]; then
      echo "install-skill-packs.sh: $id $inc has no SKILL.md children" >&2
      exit 1
    fi
  done <<< "$includes"

  local doc
  while IFS= read -r doc; do
    [[ -n "$doc" ]] || continue
    [[ -f "$checkout/$doc" ]] || { echo "install-skill-packs.sh: $id missing doc $doc" >&2; exit 1; }
    cp -f "$checkout/$doc" "$out/$doc"
  done <<< "$docs"

  local n
  n="$(find "$out" -name SKILL.md -type f | wc -l)"
  n="${n#"${n%%[![:space:]]*}"}"
  echo "install-skill-packs.sh: $id -> $dest ($n SKILL.md)"
}

copy_routers() {
  local skills_root="$1" name
  for name in "${ROUTERS[@]}"; do
    [[ -f "$ROOT/skills/$name/SKILL.md" ]] || {
      echo "install-skill-packs.sh: missing router skills/$name/SKILL.md" >&2
      exit 1
    }
    rm -rf "$skills_root/$name"
    cp -a "$ROOT/skills/$name" "$skills_root/$name"
  done
}

for id in "${PACK_IDS[@]}"; do
  key="$(vid "$id")"
  repo="$(eval "printf '%s' \"\$REPO_$key\"")"
  sha="$(eval "printf '%s' \"\$SHA_$key\"")"
  sync_checkout "$id" "$repo" "$sha"
  if (( LIST_ONLY )); then
    echo "install-skill-packs.sh: listed $id at $sha"
  fi
done

if (( LIST_ONLY )); then
  exit 0
fi

checkout_dir() {
  local repo="$1" slug
  slug="${repo#https://github.com/}"
  slug="${slug%.git}"
  slug="${slug//\//__}"
  printf '%s' "$TOOLS/$slug"
}

stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
for id in "${PACK_IDS[@]}"; do
  key="$(vid "$id")"
  repo="$(eval "printf '%s' \"\$REPO_$key\"")"
  install_pack "$id" "$(checkout_dir "$repo")" "$stage"
done
copy_routers "$stage"

if [[ -n "$HOME_DIR" ]]; then
  mkdir -p "$HOME_DIR/skills"
  cp -a "$stage/." "$HOME_DIR/skills/"
  echo "install-skill-packs.sh: wrote $HOME_DIR/skills"
  exit 0
fi

if [[ -z "$("${COMPOSE[@]}" ps -q "$SERVICE" 2>/dev/null)" ]]; then
  echo "install-skill-packs.sh: Compose agent is not running." >&2
  echo "Start it with scripts/install.sh, or pass --home HERMES_HOME." >&2
  exit 1
fi

rel=""
for id in "${PACK_IDS[@]}"; do
  rel+=" $(eval "printf '%s' \"\$DEST_$(vid "$id")\"")"
done
for name in "${ROUTERS[@]}"; do
  rel+=" $name"
done
for path in $rel; do
  "${COMPOSE[@]}" exec -T -u 0 "$SERVICE" rm -rf "/var/lib/hermes/skills/$path"
done
"${COMPOSE[@]}" exec -T -u 0 "$SERVICE" mkdir -p /var/lib/hermes/skills
tar -C "$stage" -cf - . |
  "${COMPOSE[@]}" exec -T -u 0 "$SERVICE" tar -C /var/lib/hermes/skills -xf -
"${COMPOSE[@]}" exec -T -u 0 "$SERVICE" chown -R hermes:hermes /var/lib/hermes/skills
echo "install-skill-packs.sh: copied packs into the Compose agent"
