#!/bin/bash
id=$(bspc query -N -n "focused")
if [ -n "$id" ]; then
    xprop -id $id -f _SCRATCH 32ii -set _SCRATCH $(date +%s,%N)
    bspc node -t "floating"
    xdotool windowunmap $id
fi
