#!/usr/bin/env bash
EXCLUDE_FILE="$HOME/.config/exclude.txt"
mapfile -t EXCLUDES < <(grep -vE '^\s*#|^\s*$' "$EXCLUDE_FILE")

# Copy folders and files
copy_files() {
    local source="$1"
    local destination="$2"
    local single_file="$3"

    mkdir -p "$destination"
    for item in "${ITEMS[@]}"; do
        copy_success=false
        while read -r file; do
            path="${file#$source/}"

            if [[ -n "$single_file" ]]; then
                path="${path#*/}"
            fi

            if should_exclude "$file"; then
                #echo "Excluded: $path"
                continue
            fi
            copy_success=true

            mkdir -p "$destination/$(dirname "$path")"
            cp -a "$file" "$destination/$path"
        done < <(find "$source/$item" -type f)

        if $copy_success; then
            echo "Copied: $item → ${destination#$HOME/arch_dotfiles/}/$item"
        else
            echo "❌ Failed to copy: $item"
            read -p "⚠️  Continue anyway? (y/N): " yn
            case "$yn" in
                [Nn]*) echo "🛑 Exiting script."; exit 1;;
                *) echo "⏩ Continuing...";;
            esac
        fi
    done
}

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


#------------------------------------------------------------------------
# copy base config files
SOURCE="$HOME/.config"
DESTINATION="$HOME/arch_dotfiles/config_base"

ITEMS=(
    btop
    fastfetch
    starship
    scripts
    themes
    copy_to_git.sh
)

copy_files "$SOURCE" "$DESTINATION"


#------------------------------------------------------------------------
# copy base files
SOURCE="$HOME"
DESTINATION="$HOME/arch_dotfiles"

ITEMS=(
    .bashrc
    .config/install_scripts
    .icons/Icons
    .config/Arch_sddm
)

copy_files "$SOURCE" "$DESTINATION" "true"


#------------------------------------------------------------------------
# copy desktop config files
SOURCE="$HOME/.config"
DESTINATION="$HOME/arch_dotfiles/config_desktop"

ITEMS=(
    hypr      
    kitty
    waybar
	nautilus
    swaync
    wofi
    "Code - OSS/User/settings.json"
    zen/scripts															
)

copy_files "$SOURCE" "$DESTINATION"


#------------------------------------------------------------------------
# copy server config files
SOURCE="$HOME/.config"
DESTINATION="$HOME/arch_dotfiles"
ITEMS=(
    config_server
)

copy_files "$SOURCE" "$DESTINATION"


#------------------------------------------------------------------------
# copy optional config files
SOURCE="$HOME/.config"
DESTINATION="$HOME/arch_dotfiles/.config"

ITEMS=(
    OpenRGB
)

copy_files "$SOURCE" "$DESTINATION"
