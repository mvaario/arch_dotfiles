#!/bin/bash
DEST_ROOT="$HOME/arch_dotfiles"
mkdir -p "$DEST_ROOT"

EXCLUDE_FILE="$HOME/.config/exclude.txt"
mapfile -t EXCLUDES < <(grep -vE '^\s*#|^\s*$' "$EXCLUDE_FILE")

# List of folders inside ~/.config to copy
FOLDERS=(
    "btop" 
    "fastfetch" 
    "hypr" 
    "kitty" 
    "scripts" 
    "themes" 
    "waybar" 
    "wlogout" 
    "wofi" 
    "swaync" 
    "OpenRGB/themes" 
    "OpenRGB/scripts" 
    "nautilus"
)

# Single files to copy
FILES_TO_COPY=(
    "$HOME/.config/install_scripts|$DEST_ROOT"
    "$HOME/.bashrc|$DEST_ROOT"
    "$HOME/.config/Code - OSS/User/settings.json|$DEST_ROOT/.config/Code - OSS/User"
    "$HOME/.config/copy_to_git.sh|$DEST_ROOT/.config"
    "$HOME/.config/exclude.txt|$DEST_ROOT/.config"
    "/etc/mkinitcpio.conf|$DEST_ROOT/etc"
    "/etc/modprobe.d/nvidia.conf|$DEST_ROOT/etc/modprobe.d"
    "/etc/pacman.conf|$DEST_ROOT/etc"
)

# Check excludes
should_exclude() {
    local path="$1"
    for pattern in "${EXCLUDES[@]}"; do
        if [[ "$path" == *"$pattern"* ]]; then
            return 0
        fi
    done
    return 1
}


# ---------------------------------------------------------
# copy single files
for file in "${FILES_TO_COPY[@]}"; do
    src="${file%%|*}"
    dest="${file##*|}"

    if [[ ! -e "$src" ]]; then
        echo "Skipping: $src does not exist"
        continue
    fi

    if should_exclude "$src"; then
        echo "Excluded: $src"
        continue
    fi

    mkdir -p "$dest"
    cp -a "$src" "$dest"
    echo "Copied $src → $dest"
done


# ---------------------------------------------------------
# copy .config files
DEST_ROOT="$DEST_ROOT/.config"

# Copy .config folders
for folder in "${FOLDERS[@]}"; do
    SRC="$HOME/.config/$folder"
    DEST="$DEST_ROOT/$folder"

    if [[ ! -d "$SRC" ]]; then
        echo "Skipping: $SRC does not exist"
        continue
    fi

    mkdir -p "$DEST"

    find "$SRC" -type f | while read -r file; do
        rel_path="${file#$SRC/}"
        full_rel_path="$folder/$rel_path"

        if should_exclude "$full_rel_path"; then
            echo "Excluded: $full_rel_path"
            continue
        fi
        dest_path="$DEST/$rel_path"
        mkdir -p "$(dirname "$dest_path")"
        cp "$file" "$dest_path"
    done

    echo "Copied $folder → $DEST"
done



