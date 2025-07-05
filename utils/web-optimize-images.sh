#!/bin/bash

# Resize to 500x500 with Catmull-Rom interpolation, sharpen slightly, compress to 70% quality, strip metadata
convert square.jpg -strip -interpolate catrom -resize 500x500 -unsharp 0x0.3 -quality 70% square.jpg

# Compress gallery*.jpg files to 70% quality and strip metadata
for file in gallery*.jpg; do
  # Apply the convert command to each file
  convert "$file" -strip -quality 70% "$file"
done