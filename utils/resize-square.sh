#!/bin/bash

# Strip metadata, resize to 500x500 with Catmull-Rom interpolation, sharpen slightly, compress to 70% quality
convert square.jpg -strip -interpolate catrom -resize 500x500 -unsharp 0x0.3 -quality 70% square.jpg