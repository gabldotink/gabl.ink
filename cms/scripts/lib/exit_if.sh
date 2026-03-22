# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

exit_if(){
  if [ "$errored" = true ];then
    err 'Exiting due to previous error/warning'
    if [ -n "$errored_code" ];then
      exit "$errored_code"
    else
      exit 1
    fi
  fi
}
