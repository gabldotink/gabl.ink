# shellcheck shell=sh
# SPDX-License-Identifier: CC0-1.0

zero_pad(){
  if ! printf -- '%s\n' "$1"|grep '-qe^[1-9][0-9]*$' ||
     ! eval 'printf -- "%s\n" "$'"$2"'"'|grep '-qe^[1-9][0-9]*$';then
    err e 'Both inputs to zero_pad must be positive integers'
    return 2
  fi
  eval 'printf "%0${1}d" "$'"$2"'"'
}
