# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

zero_pad(){
  eval "zero_pad_${1}_${2}"'="$(printf "%0${1}d" "${'"$2"'}")"'
}
