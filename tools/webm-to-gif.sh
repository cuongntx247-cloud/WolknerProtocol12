#!/usr/bin/env bash
# Convert a screen-recorded WebM to a high-quality GIF for README / Reddit.
# Usage: webm-to-gif.sh input.webm [output.gif] [width=800]

set -euo pipefail

INPUT="${1:?usage: $0 input.webm [output.gif] [width]}"
OUTPUT="${2:-${INPUT%.*}.gif}"
WIDTH="${3:-800}"
FPS="${FPS:-15}"

# Two-pass: build an optimal palette from the source, then render with dithering.
PALETTE="$(mktemp --suffix=.png)"
trap 'rm -f "$PALETTE"' EXIT

ffmpeg -hide_banner -loglevel warning -i "$INPUT" \
  -vf "fps=$FPS,scale=$WIDTH:-1:flags=lanczos,palettegen=stats_mode=diff" \
  -y "$PALETTE"

ffmpeg -hide_banner -loglevel warning -i "$INPUT" -i "$PALETTE" \
  -lavfi "fps=$FPS,scale=$WIDTH:-1:flags=lanczos[v];[v][1:v]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
  -loop 0 -y "$OUTPUT"

echo "wrote $OUTPUT  ($(du -h "$OUTPUT" | cut -f1))"
