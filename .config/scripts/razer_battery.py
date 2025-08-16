#!/usr/bin/env python3
import openrazer.client
import os
import json

CACHE_FILE = os.path.expanduser("~/.config/waybar/razer_battery_level")

def get_battery():
    client = openrazer.client.DeviceManager()
    devices = client.devices
    for device in devices:
        level = device.battery_level
        # write level to cache (for mice sleep)
        if level is not None and int(level) != 0:
            write_cache_level(level)
        else:
            level = read_cache_level()

        if level is not None:
            icon = get_icon(level)
            css_class = get_class(level)
            text = f"{icon} {int(level)}%"
            print(json.dumps({
                "text": text,
                "class": css_class,
                "tooltip": device.name
            }))
            return

    print(json.dumps({
        "text": " N/A",
        "class": "unknown",
        "tooltip": "No device info"
        }))

def get_icon(level):
    if level >= 90:
        return ""  # Full
    elif level >= 60:
        return ""
    elif level >= 30:
        return ""
    elif level >= 15:
        return ""
    else:
        return ""  # Low      


def get_class(level):
    if level < 10:
        return "critical"
    else:
        return "good"


def write_cache_level(level):
    try:
        with open(CACHE_FILE, "w") as f:
            f.write(str(level))
    except:
        pass

def read_cache_level():
    try:
        with open(CACHE_FILE, "r") as f:
            return int(f.read().strip())
    except:
        return None


if __name__ == "__main__":
    
    get_battery()
