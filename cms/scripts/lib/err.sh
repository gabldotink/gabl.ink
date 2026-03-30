# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

err(){
  if   [ "$1" = error ];then
    err_label_tput="$tput_bold$tput_red"
  elif [ "$1" = warning ];then
    err_label_tput="$tput_bold$tput_yellow"
  elif [ "$1" = info ];then
    err_label_tput="$tput_bold$tput_blue"
  else
    err error "Invalid error label: $1"
  fi

  err_msg_pre="[$err_label_tput$1$tput_reset]"
  [ -n "$id" ] &&
    if [ -n "$lang" ];then
      err_msg_pre="$err_msg_pre ($id/$lang)"
    else
      err_msg_pre="$err_msg_pre ($id)"
    fi
  printf -- '%s %s\n' "$err_msg_pre" "$2" >&2

  if [ "$1" = error ];then
    errored=true
    if   [ -z "$3" ];then
      errored_code=1
    elif [ "$3" -ge 1 ] &&
         [ "$3" -le 255 ];then
      errored_code="$3"
    else
      err warning "Error exit code $3 is invalid; exiting with 1"
    fi
  fi

  if [ "$1" = warning ];then
    if [ "$config_exit_on_warning" = true ];then
      errored=true
      if   [ -z "$3" ];then
        errored_code=1
      elif [ "$3" -ge 1 ] &&
           [ "$3" -le 255 ];then
        errored_code="$3"
      else
        err warning "Warning exit code $3 is invalid; exiting with 1"
      fi
    fi
    warned=true
  fi
}
