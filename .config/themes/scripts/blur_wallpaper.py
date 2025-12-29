#!/usr/bin/env python3
# script for making wlogout image look same as hyprlock and hyprland blur effects

from PIL import Image, ImageFilter, ImageEnhance, ImageChops
import os
import sys
import time
import fileinput
import re

# Hypr default noise 0.0117
def add_noise(img, noise=0.0117):
    # small amount no need
    return img

# Hypr default contrast 0.8916
def adjust_contrast(img, contrast=0.8916):
    return ImageEnhance.Contrast(img).enhance(contrast)

# Hypr default brightness 0.8172 -> updated to 1
def adjust_brightness(img, brightness=1):
    return ImageEnhance.Brightness(img).enhance(brightness)

# Hypr default vibrancy 0.1696
def adjust_vibrancy(img, vibrancy=0.1696):
    vibrancy = 1 + vibrancy
    return ImageEnhance.Color(img).enhance(vibrancy)


# Seems like impossible to match hyprland blur effect, so this will be close enough for:
# size = 4, passes = 3
# Hypr default blur size=8, passes=1 (around 15)
def add_blur(img, blur=15):
    return img.filter(ImageFilter.GaussianBlur(blur))



start = time.time()
print("Creating blured wlogout image")

# wallpaper
wallpaper_path = sys.argv[1]
img_path = os.path.expandvars(os.path.expanduser(wallpaper_path))
img = Image.open(img_path).convert("RGB")

# if changing hyprland decoration config these need to be adjusted
#img = add_noise(img)
#img = adjust_contrast(img)
#img = adjust_brightness(img)
#img = adjust_vibrancy(img)
img = add_blur(img, blur=30)


# Create a solid color image with the kitty background color
background_color_str = sys.argv[2]  # aka: 35,38,51
r, g, b = map(int, background_color_str.split(","))

overlay_color = (r, g, b)
overlay = Image.new("RGB", img.size, overlay_color)

# use same as waybar and kitty terminal
alpha = float(sys.argv[3])
blended = Image.blend(img, overlay, alpha)
output_path = os.path.expanduser("~/.config/wlogout/background/wallpaper.jpg")
blended.save(output_path)


# Mark lockfile ready
lockfile = sys.argv[4]
for line in fileinput.input(lockfile, inplace=True):
    # Replace line starting with wlogout with wlogout True
    new_line = re.sub(r"^wlogout .*", "wlogout True", line)
    sys.stdout.write(new_line)

print(f"Image edition done: {time.time()-start}")

