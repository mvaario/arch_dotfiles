#!/bin/bash
LOCKFILE="$HOME/.config/fastfetch/frames/fastfetch_anim.lock"

# Run entire script under flock to ensure single instance
exec 200>"$LOCKFILE"
flock -n 200 || { exit 1; }

trap 'tput cnorm; rm -f "$LOCKFILE"; exit' INT TERM HUP EXIT

LOGO_FILE="$HOME/.config/fastfetch/frames/logo.txt"
MASK_FILE="$HOME/.config/fastfetch/frames/mask.txt"
TEMP_LOGO="$HOME/.config/fastfetch/frames/temp_logo.txt"

# Source the hex colors
source "$HOME/.config/fastfetch/colors.conf"

# Function to convert hex to ANSI 24-bit color (foreground)
hex_to_ansi() {
    hex="$1"
    r=$((16#${hex:0:2}))
    g=$((16#${hex:2:2}))
    b=$((16#${hex:4:2}))
    echo -e "\033[38;2;${r};${g};${b}m"
}

# Reset color
RESET="\033[0m"

# Convert sourced hex colors
HIGHLIGHT_COLOR=$(hex_to_ansi "$highlight")
MAIN_COLOR=$(hex_to_ansi "$main")

mapfile -t logo_lines < "$LOGO_FILE"
mapfile -t mask_lines < "$MASK_FILE"

num_rows=${#logo_lines[@]}
tput civis
frame=0

while true; do
    # Build new frame into temp_logo.txt
    : > "$TEMP_LOGO"  # Clear previous contents
    for (( row=0; row<num_rows; row++ )); do
        logo_line="${logo_lines[$row]}"

        # Calculate corresponding mask row (with vertical shift)
        mask_row=$(( (row - frame + num_rows) % num_rows ))
        mask_line="${mask_lines[$mask_row]}"
        IFS=' ' read -r -a mask_cols <<< "$mask_line"

        output_line=""
        for (( col=0; col<${#logo_line}; col++ )); do
            char="${logo_line:$col:1}"
            if [ "$col" -lt "${#mask_cols[@]}" ]; then
                if [[ "$char" == " " ]]; then
                    output_line+=" "
                elif [ "${mask_cols[$col]}" -eq 1 ]; then
                    output_line+="${MAIN_COLOR}${char}${RESET}"
                else
                    output_line+="${HIGHLIGHT_COLOR}${char}${RESET}"
                fi
            else
                output_line+=" "
            fi
        done

        # Append the colored line to the logo file
        printf "%b\n" "$output_line" >> "$TEMP_LOGO"
    done

    # Clear screen and reset cursor, then show fastfetch with updated logo
    tput cup 0 0

    # Get terminal size (if size too small disable fastfetch infos)
    COLS=$(tput cols)
    if (( $COLS >= 90 )); then
        new_mode="full"
        fastfetch --logo "$TEMP_LOGO"
    elif (( $COLS >= 40 )); then
        new_mode="logo_only"
        fastfetch --structure none --logo "$TEMP_LOGO"
    else
        new_mode="empty"
        clear
    fi
    
    # Mode switch need clearing
    if [[ $new_mode != $mode ]]; then
        mode=$new_mode
        clear
    fi

    ((frame=(frame+1)%num_rows))

    read -t 0.25 -n 1 keypress
    if [ $? -eq 0 ]; then
        break
    fi

    if ! tty -s; then
        break
    fi
done
tput cnorm  # Restore cursor

