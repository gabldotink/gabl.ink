# shellcheck shell=sh
# shellcheck disable=SC2154
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ../build.sh only.

zero_pad(){
  zero_pad_depth="$1"
  zero_pad_integer="$2"

  printf '%0'"${zero_pad_depth}"'d\n' "${zero_pad_integer}"
}
