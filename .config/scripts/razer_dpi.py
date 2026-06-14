#!/usr/bin/env python3
import openrazer.client

DPI_X=600
DPI_Y=600
HZ=1000

def get_devices():
    client = openrazer.client.DeviceManager()
    devices = client.devices
    if len(devices) == 0:
        print("Device index out of range")
        return

    for device in devices:
        print(f"{device}: DPI: {device.dpi[0]} Hz: {device.poll_rate}")
        print("")

    return devices

def update(devices):
    for device in devices:
        update_values = None
        while update_values not in {"", "0", "1", "n", "y"}:
            update_values = input(f"Update {device} values: ").lower()
        
        if update_values in {"", "1" or "y"}:
            set_dpi(device)
            set_polling_rate(device)

    return

def set_dpi(device):
    try:
        device.dpi = (DPI_X, DPI_Y)
        print(f"DPI set to X: {DPI_X}, Y: {DPI_Y} for {device}")
    except Exception as e:
        print("Error setting DPI:", e)
    return

def set_polling_rate(device):
    try:
        device.poll_rate = HZ
        print(f"with polling rate: {HZ} for {device}")
    except Exception as e:
        print("Error setting polling rate:", e)
    return

if __name__ == "__main__":
    devices = get_devices()

    update(devices)

