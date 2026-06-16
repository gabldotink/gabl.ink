# shellcheck shell=sh
# SPDX-License-Identifier: CC0-1.0

err(){
  test_unset silent ||
    return 0

  if   [ "$1" = e ];then
    err_label="${tput_red}error"
  elif [ "$1" = w ];then
    err_label="${tput_yellow}warning"
  elif [ "$1" = i ];then
    err_label="${tput_blue}info"
  else
    err e "Invalid error label: $1"
  fi

  test_unset id ||
    if ! test_unset lang;then
      err_item=" ($tput_cyan$id$tput_reset/$tput_magenta$lang_i$tput_reset)"
    else
      err_item=" ($tput_cyan$id$tput_reset)"
    fi
  printf -- '[%s]%s %s\n' "$tput_bold$err_label$tput_reset" "$err_item" "$2" >&2

  if [ "$1" = e ];then
    errored=
    if   [ -z "$3" ];then
      errored_code=1
    elif [ "$3" -ge 1 ] &&
         [ "$3" -le 255 ];then
      errored_code="$3"
    else
      err w "Error exit code $3 is invalid; exiting with 1"
    fi
  fi

  if [ "$1" = w ];then
    if [ "$config_exit_on_warning" = true ];then
      errored=
      if   [ -z "$3" ];then
        errored_code=1
      elif [ "$3" -ge 1 ] &&
           [ "$3" -le 255 ];then
        errored_code="$3"
      else
        err w "Warning exit code $3 is invalid; exiting with 1"
      fi
    fi
    warned=true
  fi
}
