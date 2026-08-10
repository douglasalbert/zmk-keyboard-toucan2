#!/usr/bin/env bash
# Usage: draw-keymap.sh <name> [--with-combos]
# Run from repo root.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DRAW_DIR="$REPO_ROOT/draw"
CONFIG_DIR="$REPO_ROOT/config"

name="${1:?Usage: draw-keymap.sh <toucan|toucan36>}"
with_combos="${2:-}"

case "$name" in
  toucan)
    layout_args="-j $CONFIG_DIR/toucan.json"
    keymap_file="${name}.keymap"
    ;;
  toucan36)
    layout_args="-j $CONFIG_DIR/toucan36.json"
    keymap_file="${name}.keymap"
    ;;
  *)
    echo "Unknown keyboard: $name" >&2; exit 1
    ;;
esac

keymap -c "$DRAW_DIR/config.yaml" parse \
  -z "$CONFIG_DIR/$keymap_file" \
  > "$DRAW_DIR/${name}.yaml"

# Determine draw flags based on variant
if [[ "$with_combos" == "--with-combos" ]]; then
  draw_flags=""  # default: show both keys and combos
  output_name="${name}-with-combos"
else
  draw_flags="--keys-only"  # clean view: keys only
  output_name="${name}"
fi

# shellcheck disable=SC2086
keymap -c "$DRAW_DIR/config.yaml" draw \
  $layout_args \
  $draw_flags \
  "$DRAW_DIR/${name}.yaml" \
  > "$DRAW_DIR/${output_name}.svg"

echo "drew $output_name → draw/${output_name}.svg"
