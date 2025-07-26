#!/bin/sh

export background='1d1a1a'
export backerground='000000'
export foreground='ffffff'
export main='3d8e91'
export highlight='f0624b'

export black='373232'
export red='ba0e2e'
export green='3d8e91'
export yellow='f0624b'
export blue='b4b7ad'
export magenta='f0624b'
export cyan='3d8e91'
export white='ffffff'

export bblack='605656'
export bred='f03e5f'
export bgreen='71c0c3'
export byellow='f8b4a9'
export bblue='e6e7e3'
export bmagenta='f8b4a9'
export bcyan='71c0c3'
export bwhite='ffffff'

# For fastfetch animation
export fastfetch='3d8e91'
export bfastfetch='71c0c3'

export wallpaper='$HOME/.config/themes/wallpapers/bold.png'

# For nautilus and cursor
export cursor='catppuccin-mocha-teal-cursors'
export size='20'
export nautilus='Orchis-Green-Dark-Nord'
export icons='teal'

# For waybar and wlogout
export background_rgb_str=$($HOME/.config/scripts/hex_to_rgb.sh "$background")
