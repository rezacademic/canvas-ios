#!/bin/bash

# Declare an array
arr=("20x20", "29x29", "40x40", "58x58", "60x60", "76x76", "80x80", "87x87", "120x120", "152x152", "167x167", "180x180")

# Loop through each element
for element in "${arr[@]}"; do
    convert -resize $element app_icon.png $element.png
done
