#!/bin/sh
# SPDX-License-Identifier: CC0-1.0
set -x
d="$(dirname -- "$0")"
cython -3 --embed --output-file="$d/build.c" -- "$d/build.py"
# shellcheck disable=2046
gcc "$d/build.c" $(python3-config --cflags --embed --ldflags) -O2 -o "$d/build"
rm -f -- "$d/build.c"
strip -- "$d/build"
