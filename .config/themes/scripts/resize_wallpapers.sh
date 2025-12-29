#!/bin/bash
set -euo pipefail

SRC="$HOME/.config/themes/wallpapers"
DST="$HOME/.config/themes/images"

# Find jpg and png files recursively
find "$SRC" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while IFS= read -r img; do
    # Relative path from source
    rel_path="${img#$SRC/}"

    # Output path
    out="$DST/$rel_path"

    # Create destination subfolder
    mkdir -p "$(dirname "$out")"

    # Resize image (fit inside 100x100, keep aspect ratio)
    ffmpeg -loglevel error -y \
        -i "$img" \
        -vf "scale=300:150" \
        "$out"
done
