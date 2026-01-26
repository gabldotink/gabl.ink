# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ../build.sh only.

zero_pad(){
  zero_pad_depth="$1"
  zero_pad_var="$2"

  eval "zero_pad_${zero_pad_depth}_${zero_pad_var}"'="$(printf "%0${zero_pad_depth}d" "${'"${zero_pad_var}"'}")"'
}
