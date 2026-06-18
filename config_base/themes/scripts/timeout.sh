# just timeout function
start_time=$1
timeout=$2
LOCKFILE=$3

time=$(date +%s%N)
elapsed=$(( ($time - $start_time) / 1000000 ))
if [ $elapsed -gt $timeout ]; then
    echo "Theme activation timed out." >> "$LOCKFILE"
    notify-send "Theme activation timed out."
    pkill -f apply_theme.sh && exit 1
fi
sleep 0.1