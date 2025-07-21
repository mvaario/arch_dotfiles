#!/bin/bash

# Only proceed if exactly 2 files are selected
if [ "$#" -eq 2 ]; then
    meld "$1" "$2"
else
    zenity --error --text="Please select exactly two files to compare."
fi
