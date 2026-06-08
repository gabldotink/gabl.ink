# shellcheck shell=sh
# SPDX-License-Identifier: CC0-1.0

zero_pad(){
  eval 'printf "%0${1}d" "$'"$2"'"'
}
