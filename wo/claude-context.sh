#!/usr/bin/env bash
set -euo pipefail

readonly NAS_HOST=nas
readonly NAS_FOLDER=/tank/claude-context
readonly NAS_CONTEXT="$NAS_HOST:$NAS_FOLDER"
readonly NAS_STAGING_FOLDER="$NAS_FOLDER.uploading"
readonly NAS_STAGING_CONTEXT="$NAS_HOST:$NAS_STAGING_FOLDER"

CLAUDE_DIR=$(realpath -m -- "${CLAUDE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/claude}")
readonly CLAUDE_DIR
readonly -a CONTEXT_ITEMS=(
  history.jsonl
  projects
  plans
  file-history
)

staging_directory=
trap '[[ -z "$staging_directory" ]] || rm -rf -- "$staging_directory"' EXIT

require_closed_claude() {
  # The Nix package runs Claude Code as .claude-wrapped.
  if pgrep -x '\.?claude(-wrapped)?' >/dev/null; then
    echo "Claude Code is running. Close every Claude Code session before synchronizing." >&2
    exit 1
  fi
}

push_context() {
  local item
  local -a filters=()

  [[ -d "$CLAUDE_DIR/projects" ]] || {
    echo "Nothing to push, $CLAUDE_DIR/projects does not exist." >&2
    return 1
  }

  for item in "${CONTEXT_ITEMS[@]}"; do
    filters+=(--include="/$item" --include="/$item/***")
  done

  ssh "$NAS_HOST" rm -rf -- "$NAS_STAGING_FOLDER"
  ssh "$NAS_HOST" mkdir -p -- "$NAS_STAGING_FOLDER"
  rsync -a --prune-empty-dirs "${filters[@]}" --exclude='*' -- "$CLAUDE_DIR/" "$NAS_STAGING_CONTEXT/"

  # Claude Code may have started while the upload was running.
  require_closed_claude
  # These trusted paths are intentionally expanded before sending the command.
  # shellcheck disable=SC2029
  ssh "$NAS_HOST" \
    "bash -c 'if test -e \"$NAS_FOLDER\"; then mv --exchange --no-copy -T -- \"$NAS_STAGING_FOLDER\" \"$NAS_FOLDER\" && rm -rf -- \"$NAS_STAGING_FOLDER\"; else mv -- \"$NAS_STAGING_FOLDER\" \"$NAS_FOLDER\"; fi'"
}

pull_context() {
  local item

  [[ -d "$CLAUDE_DIR" ]] || {
    echo "Claude Code directory does not exist: $CLAUDE_DIR" >&2
    return 1
  }

  # CLAUDE_DIR may be a bind mount, which can't be swapped as a whole. Staging
  # inside it keeps every step below a same-filesystem rename.
  staging_directory=$(mktemp -d "$CLAUDE_DIR/.restore.XXXXXX")
  rsync -a -- "$NAS_CONTEXT/" "$staging_directory/"

  # Do not touch the live context if Claude Code started during the download.
  require_closed_claude

  for item in "${CONTEXT_ITEMS[@]}"; do
    if [[ -e "$staging_directory/$item" && -e "$CLAUDE_DIR/$item" ]]; then
      mv --exchange --no-copy -T -- "$staging_directory/$item" "$CLAUDE_DIR/$item"
    elif [[ -e "$staging_directory/$item" ]]; then
      mv --no-copy -T -- "$staging_directory/$item" "$CLAUDE_DIR/$item"
    elif [[ -e "$CLAUDE_DIR/$item" ]]; then
      mv --no-copy -T -- "$CLAUDE_DIR/$item" "$staging_directory/$item"
    fi
  done
}

case "${1:-}" in
  push)
    require_closed_claude
    push_context
    ;;
  pull)
    require_closed_claude
    pull_context
    ;;
  *)
    echo "Usage: claude-context.sh push|pull" >&2
    exit 1
    ;;
esac
