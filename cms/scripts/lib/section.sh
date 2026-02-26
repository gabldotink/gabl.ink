# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

section(){
  printf '[section %s] %s\n' "$1" "$2" >&2
}
