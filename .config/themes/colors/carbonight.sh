#!/bin/sh

export background='211f1f'
export backerground='000000'
export foreground='b0b0b0'
export main='3b3937'
export highlight='8c8c8c'

export black='3b3937'
export red='ba0e2e'
export green='c4c4c4'
export yellow='8c8c8c'
export blue='ffffff'
export magenta='eeeeee'
export cyan='ffffff'
export white='bdbdbd'

export bblack='635e5c'
export bred='f03e5f'
export bgreen='f7f7f7'
export byellow='bfbfbf'
export bblue='ffffff'
export bmagenta='ffffff'
export bcyan='ffffff'
export bwhite='e3e3e3'

# For fastfetch animation
export fastfetch='3b3937'
export bfastfetch='635e5c'

export wallpaper='$HOME/.config/themes/wallpapers/carbonight.png'

# For nautilus and cursor
export cursor='catppuccin-mocha-dark-cursors'
export size='20'
export nautilus='Orchis-Green-Dark-Nord'
export icons='black'

# For waybar and wlogout
export background_rgb_str=$($HOME/.config/scripts/hex_to_rgb.sh "$background")