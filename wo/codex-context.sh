#!/usr/bin/env bash
# Changelog (2026-09-19)
# - pull: stopped swapping the whole Codex directory with `mv --exchange`.
#   ~/.config/codex is a bind mount (preservation), and a mount point can't be
#   renamed, so every pull failed with "Device or resource busy".
# - pull: downloads into a staging folder inside the Codex directory instead,
#   then swaps each synced item and database in with a single rename. That
#   keeps the swap near-atomic without renaming the mount point, and stops
#   copying the whole directory into /tmp (RAM) on every pull.
# - pull: dropped the second `.backup` of the downloaded databases. They are
#   already validated `.backup` output from the push, so it added nothing.
# - The synced items are one list (CONTEXT_ITEMS); push builds its rsync
#   filters from it, so push and pull can't disagree on what gets synced.
# - The exit trap uses `rm -rf`: `rm -r` stopped on a prompt for every
#   read-only git pack file under .tmp when a pull failed.
set -euo pipefail

readonly NAS_HOST=nas
readonly NAS_FOLDER=/tank/codex-context
readonly NAS_CONTEXT="$NAS_HOST:$NAS_FOLDER"
readonly NAS_STAGING_FOLDER="$NAS_FOLDER.uploading"
readonly NAS_STAGING_CONTEXT="$NAS_HOST:$NAS_STAGING_FOLDER"

CODEX_DIR=$(realpath -m -- "${CODEX_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/codex}")
readonly CODEX_DIR
readonly -a DATABASES=(
  goals_1.sqlite
  memories_1.sqlite
  state_5.sqlite
  thread_history_1.sqlite
)
readonly -a CONTEXT_ITEMS=(
  history.jsonl
  session_index.jsonl
  sessions
  archived_sessions
  memories
)

temporary_directory=
staging_directory=
trap '[[ -z "$temporary_directory" ]] || rm -rf -- "$temporary_directory"; [[ -z "$staging_directory" ]] || rm -rf -- "$staging_directory"' EXIT

require_closed_codex() {
  local open_files

  command -v lsof >/dev/null || {
    echo "lsof is required to check whether Codex is running." >&2
    exit 1
  }
  open_files=$(lsof -F t +D "$CODEX_DIR" 2>/dev/null || true)

  if grep -x 'tREG' <<<"$open_files" >/dev/null; then
    echo "Codex context is in use. Close Codex before synchronizing it." >&2
    exit 1
  fi
}

validate_databases() {
  local context=$1
  local database

  for database in "${DATABASES[@]}"; do
    [[ -f "$context/databases/$database" ]] || {
      echo "Missing database: $database" >&2
      return 1
    }
    [[ $(sqlite3 "$context/databases/$database" 'PRAGMA quick_check;') == ok ]] || {
      echo "Invalid database: $database" >&2
      return 1
    }
  done
}

push_context() {
  local database item
  local -a filters=()

  for item in "${CONTEXT_ITEMS[@]}"; do
    filters+=(--include="/$item" --include="/$item/***")
  done

  temporary_directory=$(mktemp -d)
  mkdir -p -- "$temporary_directory/databases"

  for database in "${DATABASES[@]}"; do
    [[ -f "$CODEX_DIR/$database" ]] || {
      echo "Missing database: $database" >&2
      return 1
    }
    sqlite3 "$CODEX_DIR/$database" ".backup '$temporary_directory/databases/$database'"
  done

  rsync -a --prune-empty-dirs "${filters[@]}" --exclude='*' "$CODEX_DIR/" "$temporary_directory/"
  validate_databases "$temporary_directory"

  # Codex may have started while the snapshot was being prepared.
  require_closed_codex
  ssh "$NAS_HOST" rm -rf -- "$NAS_STAGING_FOLDER"
  ssh "$NAS_HOST" mkdir -p -- "$NAS_STAGING_FOLDER"
  rsync -a --delete -- "$temporary_directory/" "$NAS_STAGING_CONTEXT/"
  # These trusted paths are intentionally expanded before sending the command.
  # shellcheck disable=SC2029
  ssh "$NAS_HOST" \
    "bash -c 'if test -e \"$NAS_FOLDER\"; then mv --exchange --no-copy -T -- \"$NAS_STAGING_FOLDER\" \"$NAS_FOLDER\" && rm -rf -- \"$NAS_STAGING_FOLDER\"; else mv -- \"$NAS_STAGING_FOLDER\" \"$NAS_FOLDER\"; fi'"
}

pull_context() {
  local database item

  [[ -d "$CODEX_DIR" ]] || {
    echo "Codex directory does not exist: $CODEX_DIR" >&2
    return 1
  }

  # CODEX_DIR may be a bind mount, which can't be swapped as a whole. Staging
  # inside it keeps every step below a same-filesystem rename.
  staging_directory=$(mktemp -d "$CODEX_DIR/.restore.XXXXXX")
  rsync -a -- "$NAS_CONTEXT/" "$staging_directory/"
  validate_databases "$staging_directory"

  # Do not touch the live context if Codex started during the download.
  require_closed_codex

  for item in "${CONTEXT_ITEMS[@]}"; do
    if [[ -e "$staging_directory/$item" && -e "$CODEX_DIR/$item" ]]; then
      mv --exchange --no-copy -T -- "$staging_directory/$item" "$CODEX_DIR/$item"
    elif [[ -e "$staging_directory/$item" ]]; then
      mv --no-copy -T -- "$staging_directory/$item" "$CODEX_DIR/$item"
    elif [[ -e "$CODEX_DIR/$item" ]]; then
      mv --no-copy -T -- "$CODEX_DIR/$item" "$staging_directory/$item"
    fi
  done

  for database in "${DATABASES[@]}"; do
    rm -f -- "$CODEX_DIR/$database-wal" "$CODEX_DIR/$database-shm"
    mv -f --no-copy -T -- "$staging_directory/databases/$database" "$CODEX_DIR/$database"
  done
}

case "${1:-}" in
  push)
    require_closed_codex
    push_context
    ;;
  pull)
    require_closed_codex
    pull_context
    ;;
  *)
    echo "Usage: codex-context.sh push|pull" >&2
    exit 1
    ;;
esac
