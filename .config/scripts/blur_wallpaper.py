#!/usr/bin/env python3

from PIL import Image, ImageFilter, ImageEnhance
import os
import sys
import time

start = time.time()

# convert path to work with python
input_path = sys.argv[1]
abs_path = os.path.expandvars(input_path)
home_config = os.path.expanduser("~/.config")

wallpaper = os.path.relpath(abs_path, home_config)
wallpaper = f'../{wallpaper}'



# Open image and blur
img = Image.open(wallpaper).convert("RGB")
blurred = img.filter(ImageFilter.GaussianBlur(radius=4))


# Create a solid color image with the kitty background color
background_color_str = sys.argv[2]
r, g, b = map(int, background_color_str.split(","))

overlay_color = (r, g, b)
overlay = Image.new("RGB", blurred.size, overlay_color)


alpha = 0.1
blended = Image.blend(blurred, overlay, alpha)


blended.save("../wlogout/background/wallpaper.jpg")

print(f"Image edition took: {time.time()-start}")