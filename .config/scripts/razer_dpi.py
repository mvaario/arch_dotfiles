#!/usr/bin/env python3
import openrazer.client

def get_dpi_stage(device_index=0):
    client = openrazer.client.DeviceManager()
    devices = client.devices
    if len(devices) <= device_index:
        print("Device index out of range")
        return

    device = devices[device_index]
    print(f"Current DPI (X, Y): {device.dpi}")
    print(f"with polling rate: {device.poll_rate}")
    print("")

    return device

def set_dpi(device, dpi_x=600, dpi_y=600):
    try:
        device.dpi = (dpi_x, dpi_y)
        print(f"DPI set to X: {dpi_x}, Y: {dpi_y}")
    except Exception as e:
        print("Error setting DPI:", e)
    return

def set_polling_rate(device, hz=1000):
    try:
        device.poll_rate = hz
        print(f"with polling rate: {hz}")
    except Exception as e:
        print("Error setting polling rate:", e)
    return

if __name__ == "__main__":
    device = get_dpi_stage()
    bupdate_values = input("Set new values? ")

    try:
        bupdate_values = int(bupdate_values)
        if bupdate_values == 1:
            set_dpi(device)
            set_polling_rate(device)
    except:
        quit()



