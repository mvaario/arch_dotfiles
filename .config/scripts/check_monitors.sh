check_monitors() {
    # check if all monitors were found
    fallback=true
    current_monitors=$(hyprctl -j monitors | jq -r '.[].name')
    for monitor in "${expected_monitors[@]}"; do
        found=false
        for current in $current_monitors; do
            if [[ "$monitor" == "$current" ]]; then
                found=true
                break
            fi
        done
        if $found; then
            echo "$monitor monitor found"
            fallback=false
        else
            echo "$monitor monitor missing"
            notify-send "$monitor monitor missing"
        fi
    done
}

check_new_monitors() {
    # Check if connected monitors are missing configurations
    for current in $current_monitors; do
        found=false
        for monitor in "${expected_monitors[@]}"; do
            if [[ "$current" == "$monitor" ]]; then
                found=true
                break
            fi
        done

        if ! $found; then
            echo "Configurations missing for: $current"
            notify-send "Configurations missing for: $current"
        fi
    done
}
# --------------------------------------------------- #


# check monitors from hyprland configs
mapfile -t expected_monitors < <(
    grep '^monitor=' ~/.config/hypr/hyprland.conf \
        | sed 's/^monitor=//' \
        | cut -d',' -f1 \
        | grep -v '^$'
)

check_monitors

# if none found wait and check again
if $fallback; then
    echo "None of the expected monitors were found"
    notify-send "None of the expected monitors were found"
    sleep 5
    check_monitors
else
    check_new_monitors
fi

# still none found fallback to defauls
if $fallback; then
    sed -i 's/^monitor=/# monitor=/' ~/.config/hypr/hyprland.conf
    sed -i '1imonitor=,1920x1080@60,0x0,1' ~/.config/hypr/hyprland.conf
    hyprctl reload
    echo "Fallback to default monitors"
    notify-send "Fallback to default monitors"
fi


