#!/bin/bash
timeout=3000

# current status for swaync
if mullvad status | grep -q "Connected"; then
    connected=true
else
    connected=false
fi

# changes status
if [ "$1" = "connect" ]; then
    if $connected; then
        mullvad disconnect
        target="Disconnected"
    else
        mullvad connect
        target="Connected"
    fi

    # timeout
    start_time=$(date +%s%3N)
    while ! mullvad status | grep -q "$target"; do
        now=$(date +%s%3N)
        elapsed=$((now - start_time))

        if [ "$elapsed" -gt "$timeout" ]; then
            notify-send "Mullvad timeout"
            break
        fi

        sleep 0.1
    done

    # refresh status for swaync
    if mullvad status | grep -q "Connected"; then
        connected=true
    else
        connected=false
    fi
fi

echo "$connected"