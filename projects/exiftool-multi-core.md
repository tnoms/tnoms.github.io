# ExifTool Multi-Core Support
*May 4, 2024*

## Overview

[ExifTool](https://exiftool.org/) does not include multi-core support out of the box. This is unfortunate, because modern computers can run many processing threads at once. The workaround, as recommended by the ExifTool creator Phil Harvey, is to simply run multiple instances of ExifTool in parallel. If we run these instances in the background, we can achieve rudimentary multi-core support for ExifTool batch operations.

An automated example and walkthrough are provided. ExifTool's GPS location data tagging operation is used, because it's slow and benefits significantly from parallelization.

## Script: Parallelized GPS Tagging (Linux & MacOS)

This script below tags a large number photos with GPS location data. Photos are correlated with location tracking from a smartphone based on the time they were taken. They're then tagged with the smartphone GPS location corresponding to that point in time. This allows photos taken on a nice camera without GPS to reference to location at which they were taken and be displayed on a photo map.

Multiple instances of ExifTool are launched at once to tag thousands of photos in parallel. Each process tags photos inside a different directory, recursively. Tagging photos with GPS metadata is achieved using a GPS track log (e.g. location data exported from [Google Takeout](https://takeout.google.com/takeout/custom/local_actions,location_history,maps,mymaps)) and the [ExifTool geotagging feature](https://www.exiftool.org/geotag.html).

```
#!/bin/bash

gps_log="/path-to-gps-log/Records.json"

# Find all directories in the current directory
# Excluding root directory and sub-directories
find . -maxdepth 1 -mindepth 1 -type d -print0 |
    
    # Loop across all directories with support for special characters
    while IFS= read -r -d '' i; do
        
        # Run ExifTool GPS tagging command in the background
        nohup exiftool -if 'not $GPSLongitude' -if '$OffsetTime' -iptc:all="" '-geotime<${DateTimeOriginal}${OffsetTime}' -geotag "${gps_log}" -api GeoMaxIntSecs=0 -api GeoMaxExtSecs=10800 -api LargeFileSupport=1 -overwrite_original -m -r -ext ARW -ext CR2 -ext JPG -ext JPEG -ext TIF ${i} &
    done
```

Here's a breakdown of the lengthy ExifTool command used above: 
 - Excludes photos with existing GPSLongitude metadata: `-if 'not $GPSLongitude'`
 - Ensures UTC timezone offset metadata is included in the photo: `-if '$OffsetTime'`
 - GPS timestamps will reference DateTimeOriginal metadata combined with the UTC timezone offset: `'-geotime<${DateTimeOriginal}${OffsetTime}'`
 - GPS coordinates found within a 3-hour range of when the photo was taken are applied: `-api GeoMaxExtSecs=10800`
 - GPS coordinates are not interpolated using the closest two (no guesses): `-api GeoMaxIntSecs=0`
 - A GPS log file location is specified: `-geotag "Location History/Records_2018.json"`
 - Large file support is enabled for files >4GB
 - IPTC metadata is destroyed, because it can interfere with tagging
 - Original files are overwritten
 - Minor errors are ignored
 - Command runs recursively into all subdirectories
 - File extensions targeted are ARW, CR2, JPG, JPEG, and TIF
 - `nohup` ... `&` is applied to run the each process in the background

---
*License: [CC BY-SA 4.0 Deed](https://creativecommons.org/licenses/by-sa/4.0/) - You may copy, adapt, and use this work for any purpose, even commercial, but only if derivative works are distributed under the same license.*

*Category: Software*