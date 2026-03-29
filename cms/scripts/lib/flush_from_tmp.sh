# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

flush_from_tmp(){
  cmp -s -- "$1" "$2" >/dev/null 2>&1 ||
    cat -- "$1" > "$2"
  rm -f -- "$1"
}
