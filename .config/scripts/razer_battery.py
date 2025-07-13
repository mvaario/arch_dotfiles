#!/usr/bin/env python3
import openrazer.client
import json

def get_battery():
    client = openrazer.client.DeviceManager()
    devices = client.devices
    for device in devices:
        level = device.battery_level
        if level is not None:
            icon = get_icon(level)
            css_class = get_class(level)
            text = f"{icon} {int(level)}%"
            #print(f"{icon} {int(level)}%")
            print(json.dumps({
                "text": text,
                "class": css_class,
                "tooltip": device.name
            }))

            return
        else:
            print(json.dumps({
                "text": " N/A",
                "class": "unknown",
                "tooltip": "No battery info"
                }))
    print(json.dumps({
        "text": " N/A",
        "class": "unknown",
        "tooltip": "No battery info"
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


def set_dpi_stage(device_index=0, dpi_x=600, dpi_y=600):
    client = openrazer.client.DeviceManager()
    devices = client.devices
    if len(devices) <= device_index:
        print("Device index out of range")
        return

    device = devices[device_index]
    print(f"Current DPI (X, Y): {device.dpi}")

    try:
        device.dpi = (dpi_x, dpi_y)
        print(f"DPI set to X: {dpi_x}, Y: {dpi_y}")
    except Exception as e:
        print("Error setting DPI:", e)

if __name__ == "__main__":
    get_battery()
    #set_dpi_stage()
