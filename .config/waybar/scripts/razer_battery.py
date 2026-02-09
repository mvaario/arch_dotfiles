#!/usr/bin/env python3
import openrazer.client
import os
import json
import subprocess

NOTIFICATION_CACHE = os.path.expanduser("~/.config/waybar/razer_battery_notification")
CACHE_FILE = os.path.expanduser("~/.config/waybar/razer_battery_level")

# get battery level and charge state
def get_battery():
    client = openrazer.client.DeviceManager()
    devices = client.devices
    for device in devices:
        level = device.battery_level

        # write level to cache, for when device is sleep
        if level is not None and int(level) != 0:
            write_cache_level(level)
        else:
            level = read_cache_level()

        # Check if charging
        charging = device.is_charging       

        return level, charging, device
    return None, None, None

# write battery level to cache
def write_cache_level(level):
    try:
        with open(CACHE_FILE, "w") as f:
            f.write(str(level))
    except:
        pass

# read battery level from cache
def read_cache_level():
    try:
        with open(CACHE_FILE, "r") as f:
            return int(f.read().strip())
    except:
        return None

# Icons for waybar and notification
def get_icons(level, charging):
    if level == None:
        return None, "battery-missing"

    if level >= 90:
        waybar_icon = ""
        notification_icon = "full"
    elif level >= 60:
        waybar_icon = ""
        notification_icon = "good"

    elif level >= 30:
        waybar_icon = ""
        notification_icon = "low"
        
    elif level >= 15:
        waybar_icon = ""
        notification_icon = "low"
    else:
        waybar_icon = ""
        notification_icon = "empty"

    if charging:
        waybar_icon = "󰢝"
        notification_icon = icon = f"battery-{notification_icon}-charging"
    else:
        notification_icon = f"battery-{notification_icon}"

    return waybar_icon, notification_icon

# class for red waybar and urgent notification
def get_class(level):
    if level == None:
        return None

    if level < 15:
        battery_class =  "critical"
    else:
        battery_class = "normal"

    return battery_class

# waybar text
def waybar(waybar_icon, level, battery_class, device):
    if level != None:
        text = f"{waybar_icon} {int(level)}%"
        print(json.dumps({
            "text": text,
            "class": battery_class,
            "tooltip": device.name
        }))

    else:
        print(json.dumps({
            "text": " N/A",
            "class": "unknown",
            "tooltip": "No device info"
        }))

# read old notification
def read_notification():
    try:
        with open(NOTIFICATION_CACHE, "r") as f:
            return str(f.read().strip())
    except:
        return None

# write notification to cache
def write_notification(notification):
    try:
        with open(NOTIFICATION_CACHE, "w") as f:
            f.write(str(notification))
    except:
        pass

# create notification
def notification(notification_icon, charging):
    notify = False
    urgency = "normal"
    text = f"{level}% remaining"

    old_notification = read_notification()
    if notification_icon != old_notification:
        if charging:
            text = f"{level}% charging"
            notify = True
        elif old_notification == f"{notification_icon}-charging":
            notify = True
        elif notification_icon == "battery-low":
            notify = True
        elif notification_icon == "battery-empty":
            notify = True
            urgency = "critical"
        elif notification_icon == "battery-missing":
            notify = True

    if notify:
        # write notification cache
        write_notification(notification_icon)

        # send notification
        subprocess.run([
            "notify-send",
            "-u", urgency,
            "-i", notification_icon,
            "Razer Battery",
            text
        ])

    return


if __name__ == "__main__":
    # get level and charge
    level, charging, device = get_battery()

    # get icons
    waybar_icon, notification_icon = get_icons(level, charging)

    # get class
    battery_class = get_class(level)

    # waybar
    waybar(waybar_icon, level, battery_class, device)

    # notification
    notification(notification_icon, charging)

    #battery-full
    #battery-good
    #battery-low
    #battery-caution
    #battery-empty
    #battery-missing
    #all with -charging