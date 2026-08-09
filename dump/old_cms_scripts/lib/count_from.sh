# shellcheck shell=sh
# SPDX-License-Identifier: CC0-1.0

# This is essentially a pure shell reimplementation of seq.

count_from(){
  count_from_i="$1"
  while [ "$count_from_i" -le "$2" ];do
    printf -- '%s\n' "$count_from_i"
    count_from_i="$((count_from_i+1))"
  done
}
