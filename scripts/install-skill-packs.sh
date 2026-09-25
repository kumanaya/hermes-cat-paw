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
ROUTERS_ONLY=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [--home HERMES_HOME] [--list] [--routers-only]

  --home DIR         Install into DIR/skills (existing Hermes).
                     Default: the running Compose container.
  --list             Fetch each pin and print the pack id. Do not copy.
  --routers-only     Copy only local routers and LICENSE. Do not fetch packs.
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
    --routers-only)
      ROUTERS_ONLY=1
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

if (( LIST_ONLY && ROUTERS_ONLY )); then
  echo "install-skill-packs.sh: --list and --routers-only cannot be combined." >&2
  exit 1
fi

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

is_safe_relative() {
  local value="$1"
  local component rest
  [[ -n "$value" && "$value" != *$'\r'* && "$value" != *$'\n'* ]] || return 1
  [[ "$value" != *..* && "$value" != *\\* ]] || return 1
  case "$value" in
    /*|[A-Za-z]:*|~|~/*) return 1 ;;
  esac
  [[ "$value" != *//* && "$value" != */ ]] || return 1
  rest="$value"
  while [[ "$rest" == */* ]]; do
    component="${rest%%/*}"
    [[ -n "$component" && "$component" != "." && "$component" != ".." ]] || return 1
    rest="${rest#*/}"
  done
  [[ -n "$rest" && "$rest" != "." && "$rest" != ".." ]]
}

is_root_level_file() {
  is_safe_relative "$1" && [[ "$1" != */* && "$1" != *\\* ]]
}

is_contained_realpath() {
  local root="$1" candidate="$2" root_real candidate_real
  root_real="$(realpath -e -- "$root" 2>/dev/null)" || return 1
  candidate_real="$(realpath -e -- "$candidate" 2>/dev/null)" || return 1
  [[ "$candidate_real" == "$root_real" || "$candidate_real" == "$root_real"/* ]]
}

is_contained_destination() {
  local root="$1" candidate="$2" root_real parent_real candidate_real
  root_real="$(realpath -e -- "$root" 2>/dev/null)" || return 1
  if [[ -e "$candidate" || -L "$candidate" ]]; then
    candidate_real="$(realpath -e -- "$candidate" 2>/dev/null)" || return 1
  else
    parent_real="$(realpath -e -- "$(dirname -- "$candidate")" 2>/dev/null)" || return 1
    candidate_real="$parent_real/$(basename -- "$candidate")"
  fi
  [[ "$candidate_real" == "$root_real" || "$candidate_real" == "$root_real"/* ]]
}

validate_pin() {
  local name id key repo sha dest layout includes docs inc doc old_id old_key old_dest
  local i j
  [[ -f "$ROOT/LICENSE" ]] || {
    echo "install-skill-packs.sh: missing project LICENSE" >&2
    exit 1
  }
  ((${#ROUTERS[@]} > 0)) || {
    echo "install-skill-packs.sh: pin has no routers" >&2
    exit 1
  }
  for i in "${!ROUTERS[@]}"; do
    name="${ROUTERS[$i]}"
    if ! is_safe_relative "$name" || [[ "$name" == */* || "$name" == *\\* ]]; then
      echo "install-skill-packs.sh: invalid router $name" >&2
      exit 1
    fi
    [[ -f "$ROOT/skills/$name/SKILL.md" ]] || {
      echo "install-skill-packs.sh: missing router skills/$name/SKILL.md" >&2
      exit 1
    }
    for ((j = i + 1; j < ${#ROUTERS[@]}; j++)); do
      [[ "$name" != "${ROUTERS[$j]}" ]] || {
        echo "install-skill-packs.sh: duplicate router $name" >&2
        exit 1
      }
    done
  done
  for i in "${!PACK_IDS[@]}"; do
    id="${PACK_IDS[$i]}"
    key="$(vid "$id")"
    repo="$(eval "printf '%s' \"\$REPO_$key\"")"
    sha="$(eval "printf '%s' \"\$SHA_$key\"")"
    dest="$(eval "printf '%s' \"\$DEST_$key\"")"
    layout="$(eval "printf '%s' \"\$LAYOUT_$key\"")"
    includes="$(eval "printf '%s' \"\$INCLUDE_$key\"")"
    docs="$(eval "printf '%s' \"\$DOC_$key\"")"
    for ((j = 0; j < i; j++)); do
      old_id="${PACK_IDS[$j]}"
      old_key="$(vid "$old_id")"
      old_dest="$(eval "printf '%s' \"\$DEST_$old_key\"")"
      [[ "$id" != "$old_id" ]] || {
        echo "install-skill-packs.sh: duplicate pack $id" >&2
        exit 1
      }
      [[ "$dest" != "$old_dest" ]] || {
        echo "install-skill-packs.sh: duplicate destination $dest" >&2
        exit 1
      }
    done
    [[ -n "$id" && -n "$repo" && -n "$sha" && -n "$dest" ]] || {
      echo "install-skill-packs.sh: incomplete pack $id" >&2
      exit 1
    }
    [[ "$dest" != "." ]] || {
      echo "install-skill-packs.sh: invalid destination $dest" >&2
      exit 1
    }
    is_safe_relative "$dest" || {
      echo "install-skill-packs.sh: invalid destination $dest" >&2
      exit 1
    }
    [[ "$layout" == "flat" || "$layout" == "grouped" ]] || {
      echo "install-skill-packs.sh: $id layout must be flat or grouped" >&2
      exit 1
    }
    [[ -n "$includes" ]] || {
      echo "install-skill-packs.sh: $id has no include paths" >&2
      exit 1
    }
    while IFS= read -r inc; do
      [[ -n "$inc" ]] || continue
      is_safe_relative "$inc" || {
        echo "install-skill-packs.sh: invalid include $inc" >&2
        exit 1
      }
    done <<< "$includes"
    while IFS= read -r doc; do
      [[ -n "$doc" ]] || continue
      is_root_level_file "$doc" || {
        echo "install-skill-packs.sh: invalid doc $doc" >&2
        exit 1
      }
    done <<< "$docs"
  done
}

validate_pin

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
  rm -rf "${parent:?}/${name:?}"
  mkdir -p "$parent"
  cp -a "$src" "$parent/$name"
}

install_pack() {
  local id="$1" checkout="$2" skills_root="$3"
  local key repo sha dest layout includes excludes docs
  local checkout_real skills_root_real out out_real
  local inc src src_real parent child name kept
  local target resolved link skill_file skill_real doc doc_src doc_dest n
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
  [[ "$dest" != "." ]] || {
    echo "install-skill-packs.sh: invalid destination $dest" >&2
    exit 1
  }
  is_safe_relative "$dest" || {
    echo "install-skill-packs.sh: invalid destination $dest" >&2
    exit 1
  }
  [[ "$layout" == "flat" || "$layout" == "grouped" ]] || {
    echo "install-skill-packs.sh: $id layout must be flat or grouped" >&2
    exit 1
  }
  if ! checkout_real="$(realpath -e -- "$checkout" 2>/dev/null)"; then
    echo "install-skill-packs.sh: cannot resolve checkout $checkout" >&2
    exit 1
  fi
  if ! skills_root_real="$(realpath -e -- "$skills_root" 2>/dev/null)"; then
    echo "install-skill-packs.sh: cannot resolve skills root $skills_root" >&2
    exit 1
  fi
  out="$skills_root/$dest"
  rm -rf "$out"
  mkdir -p "$out"
  if ! out_real="$(realpath -e -- "$out" 2>/dev/null)"; then
    echo "install-skill-packs.sh: cannot resolve destination $dest" >&2
    exit 1
  fi
  case "$out_real" in
    "$skills_root_real"/*) ;;
    *)
      echo "install-skill-packs.sh: destination escapes skills root: $dest" >&2
      exit 1
      ;;
  esac

  while IFS= read -r inc; do
    [[ -n "$inc" ]] || continue
    is_safe_relative "$inc" || {
      echo "install-skill-packs.sh: invalid include $inc" >&2
      exit 1
    }
    src="$checkout/$inc"
    if ! src_real="$(realpath -e -- "$src" 2>/dev/null)" || [[ ! -d "$src_real" ]]; then
      echo "install-skill-packs.sh: $id missing $inc" >&2
      exit 1
    fi
    case "$src_real" in
      "$checkout_real"/*) ;;
      *)
        echo "install-skill-packs.sh: $id include escapes checkout: $inc" >&2
        exit 1
        ;;
    esac
    src="$src_real"
    skill_file="$src/SKILL.md"
    if [[ -f "$skill_file" ]]; then
      if ! skill_real="$(realpath -e -- "$skill_file" 2>/dev/null)"; then
        echo "install-skill-packs.sh: cannot resolve $inc/SKILL.md" >&2
        exit 1
      fi
      case "$skill_real" in
        "$checkout_real"/*) ;;
        *)
          echo "install-skill-packs.sh: $inc/SKILL.md escapes checkout" >&2
          exit 1
          ;;
      esac
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
      if [[ -L "$child" ]]; then
        if ! resolved="$(realpath -e -- "$child" 2>/dev/null)"; then
          continue
        fi
        case "$resolved" in
          "$checkout_real"/*) ;;
          *) continue ;;
        esac
        [[ -d "$resolved" ]] || continue
        skill_file="$resolved/SKILL.md"
        if ! skill_real="$(realpath -e -- "$skill_file" 2>/dev/null)"; then
          continue
        fi
        case "$skill_real" in
          "$checkout_real"/*) ;;
          *) continue ;;
        esac
        [[ -f "$skill_real" ]] || continue
        target="$resolved"
      elif [[ -f "$child/SKILL.md" ]]; then
        if ! skill_real="$(realpath -e -- "$child/SKILL.md" 2>/dev/null)"; then
          continue
        fi
        case "$skill_real" in
          "$checkout_real"/*) ;;
          *) continue ;;
        esac
        target="$child"
      else
        # Git symlink checked out as a text file (core.symlinks=false).
        [[ -f "$child" && ! -d "$child" ]] || continue
        link="$(tr -d '\r\n' < "$child")"
        case "$link" in
          *[!A-Za-z0-9_./-]*|"") continue ;;
        esac
        if ! resolved="$(realpath -e -- "$src/$link" 2>/dev/null)"; then
          continue
        fi
        case "$resolved" in
          "$checkout_real"/*) ;;
          *) continue ;;
        esac
        [[ -d "$resolved" ]] || continue
        skill_file="$resolved/SKILL.md"
        if ! skill_real="$(realpath -e -- "$skill_file" 2>/dev/null)"; then
          continue
        fi
        case "$skill_real" in
          "$checkout_real"/*) ;;
          *) continue ;;
        esac
        [[ -f "$skill_real" ]] || continue
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

  while IFS= read -r doc; do
    [[ -n "$doc" ]] || continue
    is_root_level_file "$doc" || {
      echo "install-skill-packs.sh: invalid doc $doc" >&2
      exit 1
    }
    doc_src="$checkout/$doc"
    [[ -f "$doc_src" ]] || {
      echo "install-skill-packs.sh: $id missing doc $doc" >&2
      exit 1
    }
    is_contained_realpath "$checkout_real" "$doc_src" || {
      echo "install-skill-packs.sh: $id doc escapes checkout: $doc" >&2
      exit 1
    }
    doc_dest="$out/$doc"
    is_contained_destination "$out_real" "$doc_dest" || {
      echo "install-skill-packs.sh: $id doc escapes destination: $doc" >&2
      exit 1
    }
    [[ ! -d "$doc_dest" ]] || {
      echo "install-skill-packs.sh: $id doc destination is a directory: $doc" >&2
      exit 1
    }
    cp -f -- "$doc_src" "$doc_dest"
    is_contained_destination "$out_real" "$doc_dest" || {
      echo "install-skill-packs.sh: $id doc copy escaped destination: $doc" >&2
      exit 1
    }
  done <<< "$docs"

  n="$(find -L "$out" -name SKILL.md -type f -print 2>/dev/null | wc -l)"
  n="${n#"${n%%[![:space:]]*}"}"
  [[ "$n" =~ ^[0-9]+$ && "$n" -gt 0 ]] || {
    echo "install-skill-packs.sh: $id installed zero SKILL.md files" >&2
    exit 1
  }
  echo "install-skill-packs.sh: $id -> $dest ($n SKILL.md)"
}

copy_routers() {
  local skills_root="$1" name
  mkdir -p "$skills_root"
  for name in "${ROUTERS[@]}"; do
    [[ -f "$ROOT/skills/$name/SKILL.md" ]] || {
      echo "install-skill-packs.sh: missing router skills/$name/SKILL.md" >&2
      exit 1
    }
    rm -rf "${skills_root:?}/${name:?}"
    cp -a "$ROOT/skills/$name" "$skills_root/$name"
  done
  cp -f "$ROOT/LICENSE" "$skills_root/LICENSE.hermes-cat-paw"
}

if (( LIST_ONLY )); then
  for id in "${PACK_IDS[@]}"; do
    key="$(vid "$id")"
    repo="$(eval "printf '%s' \"\$REPO_$key\"")"
    sha="$(eval "printf '%s' \"\$SHA_$key\"")"
    sync_checkout "$id" "$repo" "$sha"
    echo "install-skill-packs.sh: listed $id at $sha"
  done
  exit 0
fi

checkout_dir() {
  local repo="$1" slug
  slug="${repo#https://github.com/}"
  slug="${slug%.git}"
  slug="${slug//\//__}"
  printf '%s' "$TOOLS/$slug"
}

remove_managed_paths() {
  local skills_root="$1" include_packs="$2" name id key dest
  mkdir -p "$skills_root"
  for name in "${ROUTERS[@]}"; do
    rm -rf "${skills_root:?}/${name:?}"
  done
  if (( include_packs )); then
    for id in "${PACK_IDS[@]}"; do
      key="$(vid "$id")"
      dest="$(eval "printf '%s' \"\$DEST_$key\"")"
      rm -rf "${skills_root:?}/${dest:?}"
    done
  fi
  rm -f "$skills_root/LICENSE.hermes-cat-paw"
}

stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
if (( ROUTERS_ONLY )); then
  copy_routers "$stage"
else
  for id in "${PACK_IDS[@]}"; do
    key="$(vid "$id")"
    repo="$(eval "printf '%s' \"\$REPO_$key\"")"
    sync_checkout "$id" "$repo" "$(eval "printf '%s' \"\$SHA_$key\"")"
    install_pack "$id" "$(checkout_dir "$repo")" "$stage"
  done
  copy_routers "$stage"
fi

if [[ -n "$HOME_DIR" ]]; then
  skills="$HOME_DIR/skills"
  remove_managed_paths "$skills" "$(( ! ROUTERS_ONLY ))"
  cp -a "$stage/." "$skills/"
  echo "install-skill-packs.sh: wrote $skills"
  exit 0
fi

if [[ -z "$("${COMPOSE[@]}" ps -q "$SERVICE" 2>/dev/null)" ]]; then
  echo "install-skill-packs.sh: Compose agent is not running." >&2
  echo "Start it with scripts/install.sh, or pass --home HERMES_HOME." >&2
  exit 1
fi

paths=()
for name in "${ROUTERS[@]}"; do
  paths+=("$name")
done
if (( ! ROUTERS_ONLY )); then
  for id in "${PACK_IDS[@]}"; do
    paths+=("$(eval "printf '%s' \"\$DEST_$(vid "$id")\"")")
  done
fi
for path in "${paths[@]}"; do
  "${COMPOSE[@]}" exec -T -u 0 "$SERVICE" rm -rf "/var/lib/hermes/skills/$path"
done
"${COMPOSE[@]}" exec -T -u 0 "$SERVICE" rm -f /var/lib/hermes/skills/LICENSE.hermes-cat-paw
"${COMPOSE[@]}" exec -T -u 0 "$SERVICE" mkdir -p /var/lib/hermes/skills
tar -C "$stage" -cf - . |
  "${COMPOSE[@]}" exec -T -u 0 "$SERVICE" tar -C /var/lib/hermes/skills -xf -
"${COMPOSE[@]}" exec -T -u 0 "$SERVICE" chown -R hermes:hermes /var/lib/hermes/skills
echo "install-skill-packs.sh: copied packs into the Compose agent"
