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

outside_start=0


# using temp file to because stupid things
key_flag_file="$HOME/.config/wofi/wofi_keypress_flag"
echo "false" > "$key_flag_file"

# getting keyboard inputs (will probably cause some memory leak but cba)
libinput debug-events --device /dev/input/event2 | while read -r line; do
    if echo "$line" | grep -q "KEY_ESC.*pressed"; then
        kill "$wofi_pid"
        exit 0
    elif echo "$line" | grep -q "KEY.*pressed"; then
        echo "true" > "$key_flag_file"
    fi
done &
libinput_pid=$!

# trap lister, no idea how it works if it even does
trap 'kill "$libinput_pid"' EXIT INT TERM


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

    # reset time
    if [[ "$key_flag" == "true" ]]; then
        outside_start=0
        echo "false" > "$key_flag_file"
    fi

    # if cursor inside wofi
    if (( cx < x || cx > x2 || cy < y || cy > y2 )); then
        if (( outside_start == 0 )); then
            outside_start=$(date +%s%3N)
        else
            now=$(date +%s%3N)  # current time in milliseconds
            elapsed=$(( now - outside_start ))
            echo "$elapsed"
            #echo "$now"
            #echo "$outside_start"
            if (( elapsed >= 1000 )); then  # 2000 ms = 2.0 seconds
                kill "$wofi_pid"
                kill "$libinput_pid"
                break
            fi
        fi
    else
        outside_start=0
    fi

done
