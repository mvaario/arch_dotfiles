#!/bin/bash

# Kill if already running
if pgrep -x wofi > /dev/null 2>&1; then
    killall wofi
    exit
fi


# Build Wofi command
if [[ $# -gt 0 ]]; then
    wofi --show drun -y 10 -x 10 &
else
    wofi --show drun &
fi

#save if
wofi_pid=$!

# keyboard temp flag
key_flag_file="$HOME/.config/wofi/wofi_keypress_flag"
echo "false" > "$key_flag_file"
# getting keyboard inputs
libinput debug-events --device /dev/input/event2 | while read -r line; do
    if echo "$line" | grep -q "KEY.*pressed"; then
        echo "true" > "$key_flag_file"
        echo "keyboard pressed"
    fi
done &
keyboard_pid=$!

# mouse temp flag
mouse_flag_file="$HOME/.config/wofi/wofi_mouse_flag"
echo "false" > "$mouse_flag_file"
# check mouse inputs
libinput debug-events --device /dev/input/event8 | while read -r line; do
    if echo "$line" | grep -q "BTN_LEFT.*pressed"; then
        echo "true" > "$mouse_flag_file"
        echo "right click pressed"
    fi
done &
mouse_pid=$!


# trap lister, no idea how it works if it even does
trap 'kill "$keyboard_pid"' EXIT INT TERM
trap 'kill "$mouse_pid"' EXIT INT TERM
outside_start=0
while true; do
    sleep 0.2
    # read wofi window position
    read -r x y w h <<< "$(hyprctl layers | grep 'namespace: wofi' | sed -n 's/.*xywh: \([-0-9 ]*\), namespace.*/\1/p')"
    x2=$(( x + w ))
    y2=$(( y + h ))

    # read cursor position
    read cx cy < <(hyprctl cursorpos | tr -d ',')

    # check if keyboard is pressed
    if [[ -f $key_flag_file ]]; then
        key_flag=$(cat "$key_flag_file")
    else
        key_flag="false"
    fi

    # check if mouse is pressed
    if [[ -f $mouse_flag_file ]]; then
        mouse_flag=$(cat "$mouse_flag_file")
    else
        mouse_flag="false"
    fi


    # reset time
    if [[ "$key_flag" == "true" ]]; then
        outside_start=0
        echo "false" > "$key_flag_file"
    fi


    # if cursor inside wofi
    if (( cx < x || cx > x2 || cy < y || cy > y2 )); then
        if (( outside_start == 0 )); then
            outside_start=$(date +%s%3N)
            echo "time reset"
        else
            now=$(date +%s%3N)  # current time in milliseconds
            elapsed=$(( now - outside_start ))
            echo "$elapsed"
            #
            if (( elapsed >= 1000 )) || [[ "$mouse_flag" == "true" ]]; then
                kill "$wofi_pid"
                kill "$keyboard_pid"  2>/dev/null
                kill "$mouse_pid" 2>/dev/null
                break
            fi

        fi
    else
        outside_start=0
    fi


done
kill "$wofi_pid"
kill "$keyboard_pid"  2>/dev/null
kill "$mouse_pid" 2>/dev/null