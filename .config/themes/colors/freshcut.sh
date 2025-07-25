#!/bin/sh

export background='f2f2f2'
export backerground='ffffff'
export foreground='2f3030'
export main='83aa29'
export highlight='008299'

export black='ffffff'
export red='ba0e2e'
export green='3da09a'
export yellow='008299'
export blue='83aa29'
export magenta='8e99a5'
export cyan='3ba099'
export white='3c3d3d'

export bblack='ffffff'
export bred='f03e5f'
export bgreen='78cbc6'
export byellow='00d9ff'
export bblue='b4d960'
export bmagenta='c7ccd2'
export bcyan='75ccc6'
export bwhite='616464'

# For fastfetch animation
export fastfetch='83aa29'
export bfastfetch='b4d960'

export wallpaper='$HOME/.config/themes/wallpapers/freshcut.jpg'

# For nautilus and cursor
export cursor='catppuccin-mocha-light-cursors'
export size='20'
export nautilus='Orchis-Green-Dark-Nord'
export icons='white'

# For waybar and wlogout
export background_rgb_str=$($HOME/.config/scripts/hex_to_rgb.sh "$background")