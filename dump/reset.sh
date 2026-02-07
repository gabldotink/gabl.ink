#!/bin/sh
rm -f image_with_metadata.png image_with_metadata.png_original
cp image.png image_with_metadata.png
exiftool -api LargeFileSupport=1 -api ImageHashType=SHA256 -@ ./exiftool_meta.txt ./image_with_metadata.png
exiftool -G -a ./image_with_metadata.png
