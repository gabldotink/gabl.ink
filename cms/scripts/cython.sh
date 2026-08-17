#!/bin/sh
# SPDX-License-Identifier: CC0-1.0
d="$(dirname -- "$0")"
cython --embed "-3o$d/build.c" -- "$d/build.py"
# shellcheck disable=2046
gcc -Ofast $(python3-config --cflags) $(python3-config --embed --ldflags) "-o$d/build" "$d/build.c"
rm -f -- "$d/build.c"
strip -- "$d/build"
