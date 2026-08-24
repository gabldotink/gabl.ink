#!/bin/sh
# SPDX-License-Identifier: CC0-1.0
d="$(dirname -- "$0")"
cython -3 --embed --output-file="$d/gabel/build.c" -- "$d/gabel/build.py"
# shellcheck disable=2046
gcc "$d/gabel/build.c" $(python3-config --cflags --embed --ldflags) -O2 -o "$d/gabel/build"
rm -f -- "$d/gabel/build.c"
strip -- "$d/gabel/build"
