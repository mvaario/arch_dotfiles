#!/bin/sh
export opacity='0.6'

export background='2b282b'     
export foreground='c0ccdb'      
export main='9c27b0'            
export highlight='C34AEE'

export black='1a1a1a'     # dark neutral black
export red='ba0e2e'       # strong true red (kept)
export green='4caf50'     # classic soft green
export yellow='ffb300'    # warm yellow-orange
export blue='2196f3'      # true blue
export magenta='9c27b0'   # proper magenta
export cyan='00acc1'      # fresh cyan/teal
export white='f1decb'     # keeping soft white for warmth

export bblack='2b2b2b'     # warm dark gray
export bred='ba0e2e'       # muted red (kept)
export bgreen='769958'     # muted olive green
export byellow='c99a3a'    # deep goldenrod
export bblue='54787d'      # desaturated slate blue
export bmagenta='b56a8d'   # soft wine/pink
export bcyan='569c9b'      # dusty teal
export bwhite='f1decb'     # soft cream

# For nautilus and cursor
export cursor='catppuccin-mocha-mauve-cursors'
export size='20'
export nautilus='Orchis-Purple-Dark-Nord'
export icons='magenta'
export name='magenta'

# For waybar and wlogout
export background_rgb_str=$($HOME/.config/scripts/hex_to_rgb.sh "$background")

export wallpaper='$HOME/.config/themes/wallpapers/jewel.jpg'

#openrgb profile
export openrgb="openrgb_orange"