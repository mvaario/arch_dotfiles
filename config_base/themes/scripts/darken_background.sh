#!/usr/bin/env bash
COLOR="$1"
R_AMOUNT=7
G_AMOUNT=8
B_AMOUNT=6

R=$((16#${COLOR:0:2}))
G=$((16#${COLOR:2:2}))
B=$((16#${COLOR:4:2}))

R=$(( R - R_AMOUNT ))
G=$(( G - G_AMOUNT ))
B=$(( B - B_AMOUNT ))
[ $R -lt 0 ] && R=0
[ $G -lt 0 ] && G=0
[ $B -lt 0 ] && B=0

printf "%02X%02X%02X\n" $R $G $B