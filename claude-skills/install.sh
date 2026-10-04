#!/usr/bin/env bash
# claude-skills installer — copies (or links) this set into ~/.claude/skills/
# Usage:
#   ./install.sh            copy skills into ~/.claude/skills/
#   ./install.sh --link     symlink instead of copy (handy during development)
#   ./install.sh --dry-run  show what would happen, change nothing
#   DEST=/custom/path ./install.sh    override destination
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/skills" && pwd)"
DEST="${DEST:-$HOME/.claude/skills}"
MODE="copy"
DRY=0

for arg in "$@"; do
  case "$arg" in
    --link) MODE="link" ;;
    --dry-run) DRY=1 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

echo "source: $SRC_DIR"
echo "dest:   $DEST"
echo "mode:   $MODE$([ "$DRY" = 1 ] && echo ' (dry-run)')"
echo

[ "$DRY" = 1 ] || mkdir -p "$DEST"

for skill in "$SRC_DIR"/*/; do
  name="$(basename "$skill")"
  target="$DEST/$name"
  if [ ! -f "$skill/SKILL.md" ]; then continue; fi
  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "replace  $name"
    [ "$DRY" = 1 ] || rm -rf "$target"
  else
    echo "install  $name"
  fi
  if [ "$DRY" = 1 ]; then continue; fi
  if [ "$MODE" = "link" ]; then
    ln -s "${skill%/}" "$target"
  else
    cp -R "$skill" "$target"
  fi
done

echo
echo "done. Installed skills live under: $DEST"
echo "Next: enable the external plugins/CLIs described in docs/bridges.md"
