# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

err(){
  if [ "$1" = error ];then
    err_label_tput="$tput_error"
  elif [ "$1" = warning ];then
    err_label_tput="$tput_warning"
  fi

  [ -n "$1" ] &&
    printf -- '[%s%s%s] ' "$err_label_tput" "$1" "$tput_reset" >&2
  [ -n "$id" ] &&
    printf -- '(%s/%s) ' "$id" "$lang" >&2
  printf -- '%s\n' "$2" >&2

  if [ "$1" = error ];then
    errored=true
    if   [ -z "$3" ];then
      exit 1
    elif [ "$3" -lt 1 ] ||
         [ "$3" -gt 255 ];then
      err error "Error exit code $3 is invalid; exiting with 1"
    fi
  fi

  if [ "$1" = warning ];then
    if [ "$config_exit_on_warning" = true ];then
      errored=true
      if   [ -z "$3" ];then
        exit 1
      elif [ "$3" -lt 1 ] ||
           [ "$3" -gt 255 ];then
        err error "Warning exit code $3 is invalid; exiting with 1"
      fi
    fi
    warned=true
  fi
}
