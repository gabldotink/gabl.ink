#!/bin/sh
rm -f image_with_metadata.png image_with_metadata.png_original
cp image.png image_with_metadata.png
exiftool -@ ./exiftool_meta.txt ./image_with_metadata.png
exiftool -a -G ./image_with_metadata.png
