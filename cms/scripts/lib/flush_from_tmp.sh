# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

flush_from_tmp(){
  if ! cmp -s -- "$1" "$2" >/dev/null 2>&1;then
    cat -- "$1" > "$2"
  fi
  rm -f -- "$1"
}
