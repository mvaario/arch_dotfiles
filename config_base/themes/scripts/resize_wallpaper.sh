#!/bin/bash
SRC="$HOME/.config/themes/wallpapers"
DST="$HOME/.config/themes/images"

process_image() {
    local img="$1"

    rel_path="${img#$SRC/}"
    out="$DST/$rel_path"

    mkdir -p "$(dirname "$out")"

    ffmpeg -loglevel error -y \
        -i "$img" \
        -vf "scale=300:150" \
        "$out"

    echo "$out"
}

# Resize only the passed image
if [ "${1:-}" != "" ]; then
    find "$SRC" -type f \( -iname "$1.jpg" -o -iname "$1.jpeg" -o -iname "$1.png" \) | while IFS= read -r img; do
        process_image "$img"
    done
else
    # Delete old image files
    rm -rf "$DST"/*

    # Resize all the images
    find "$SRC" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while IFS= read -r img; do
        process_image "$img"
    done
fi