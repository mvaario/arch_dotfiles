#!/bin/bash

# Kill if already running
if pgrep -x wofi > /dev/null 2>&1; then
    killall wofi
    exit
fi

# wofi window positionS
case "$1" in
    menu)
        wofi --show drun -y 10 -x 10 &
        ;;
    theme_selection)
        printf '%s\n' "$2" | wofi --show dmenu --conf="$HOME/.config/wofi/theme_config" > ~/.config/wofi/temp &
        ;;
    *)
    wofi --show drun &
    ;;
esac
#save pid
wofi_pid=$!

# mouse listener
mouse_flag_file="$HOME/.config/wofi/wofi_mouse_flag"
echo "false" > "$mouse_flag_file"
mouse_device=$(libinput list-devices | awk -v RS= '/Capabilities:.*pointer/{for(i=1;i<=NF;i++) if($i=="Kernel:") print $(i+1); exit}')
libinput debug-events --device $mouse_device | while read -r line; do
    # echo "$line"
    if echo "$line" | grep -q "BTN_LEFT.*pressed"; then
        echo "true" > "$mouse_flag_file"
        echo "right click pressed"
    fi
done &
mouse_pid=$!

# trap lister, no idea how it works if it even does
# trap 'kill "$keyboard_pid"' EXIT INT TERM
trap 'kill "$mouse_pid"' EXIT INT TERM
outside_start=0
outside_maxtime=3000
while true; do
    sleep 0.1
    
    # read mouse flag file
    mouse_flag=$(cat "$mouse_flag_file")

    # read wofi window position
    read -r x y w h <<< "$(hyprctl layers | grep 'namespace: wofi' | sed -n 's/.*xywh: \([-0-9 ]*\), namespace.*/\1/p')"
    x2=$(( x + w ))
    y2=$(( y + h ))

    # read cursor position
    read cx cy < <(hyprctl cursorpos | tr -d ',')

    # if cursor outside wofi
    if (( cx < x || cx > x2 || cy < y || cy > y2 )); then
        if (( outside_start == 0 )); then
            outside_start=$(date +%s%3N)
            echo "time reset"
        else
            now=$(date +%s%3N)  # current time in milliseconds
            elapsed=$(( now - outside_start ))
            echo "$elapsed"
            if (( elapsed >= outside_maxtime )) || [[ "$mouse_flag" == "true" ]]; then
                break
            fi

        fi
    else
        outside_start=0
    fi

    # Check if wofi is closed
    if ! pgrep -x wofi >/dev/null; then
        break
    fi

    # if theme is selected
    if [[ "$1" == "theme_selection" ]]; then
        if [[ -s ~/.config/wofi/temp ]]; then
            break
        fi
    fi
done
kill "$wofi_pid"
kill "$mouse_pid"
# kill "$keyboard_pid"