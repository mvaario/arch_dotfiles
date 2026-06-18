#!/usr/bin/env bash

opacity="$1"

# Remove decimal point and get two digits after decimal
decimal_part="${opacity#*.}"
integer_part="${opacity%.*}"

# Pad decimal part to 2 digits
decimal_part="${decimal_part}00"
decimal_part="${decimal_part:0:2}"

# Convert to integer 0-100 scale
opacity_scaled=$(( integer_part * 100 + 10#$decimal_part ))

# Calculate alpha value (0-255)
alpha=$(( (opacity_scaled * 255) / 100 ))

# Clamp alpha between 0 and 255
(( alpha < 0 )) && alpha=0
(( alpha > 255 )) && alpha=255

# Convert to hex
printf "%02x\n" "$alpha"