#!/bin/sh

export background='282c2c'
export backerground='000000'
export foreground='d6dbdb'
export main='c24e4b'
export highlight='9bb7a7'

export black='404646'
export red='ba0e2e'
export green='c24e4b'
export yellow='9bb7a7'
export blue='f9f7f1'
export magenta='9bb7a7'
export cyan='c24e4b'
export white='e4e7e7'

export bblack='656e6e'
export bred='f03e5f'
export bgreen='dc9997'
export byellow='d6e2db'
export bblue='ffffff'
export bmagenta='d6e2db'
export bcyan='dc9997'
export bwhite='ffffff'

# For fastfetch animation
export fastfetch='c24e4b'
export bfastfetch='dc9997'

export wallpaper='$HOME/.config/themes/wallpapers/comrade.png'

# For nautilus and cursor
export cursor='catppuccin-mocha-red-cursors'
export size='20'
export nautilus='Orchis-Green-Dark-Nord'
export icons='red'

# For waybar and wlogout
export background_rgb_str=$($HOME/.config/scripts/hex_to_rgb.sh "$background")