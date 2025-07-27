#!/usr/bin/env python3
from PIL import Image, ImageFilter, ImageEnhance
import os
import sys
import time

start = time.time()
print("Creating blured wlogout image")

input_path = sys.argv[1]
img_path = os.path.expandvars(os.path.expanduser(input_path))

img = Image.open(img_path).convert("RGB")

blurred = img.filter(ImageFilter.GaussianBlur(radius=4))

# Create a solid color image with the kitty background color
background_color_str = sys.argv[2]
r, g, b = map(int, background_color_str.split(","))

overlay_color = (r, g, b)
overlay = Image.new("RGB", blurred.size, overlay_color)


alpha = 0.1
blended = Image.blend(blurred, overlay, alpha)

output_path = os.path.expanduser("~/.config/wlogout/background/wallpaper.jpg")
blended.save(output_path)

print(f"Image edition done: {time.time()-start}")