#!/usr/bin/env python3
import openrazer.client

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
    set_dpi_stage()
