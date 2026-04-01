# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

config_get(){
  if [ "$#" -eq 1 ];then
    eval 'printf "%s" "$config_'"$1"'"'
  else
    err error 'config_get must have 0 or 1 arguments'
  fi
}
