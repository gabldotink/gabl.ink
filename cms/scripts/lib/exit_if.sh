# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

exit_if(){
  if [ "$errored" = true ];then
    exit 1
  fi
}
