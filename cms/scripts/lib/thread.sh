# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

thread(){
  [ "$max_threads" -le 0 ] &&
    exit 0
  if   [ -z "$1" ]||
       [ "$1" = + ];then
    if [ "$(cat "$threads")" -ge "$max_threads" ];then
      err info 'waiting for thread'
      while [ "$(cat "$threads")" -ge "$max_threads" ];do
        :
      done
    fi
    [ "$1" = + ] &&
      printf '%s\n' "$(("$(cat "$threads")"+1))" > "$threads"
  elif [ "$1" = - ];then
    printf '%s\n' "$(("$(cat "$threads")"-1))" > "$threads"
  else
    err error "invalid instruction to thread function: $1"
  fi
}
