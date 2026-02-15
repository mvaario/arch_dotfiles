#!/bin/bash

if pgrep -f 'kitty --title btop-monitor' > /dev/null; then
    pkill -f 'kitty --title btop-monitor'
else
    kitty --title btop-monitor btop
fi