# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ../build.sh only.

error(){
  error_msg="$1"
  error_exit_code="$2"
  printf 'error: ' >&2
  [ -n "${id}" ] &&
    printf '%s: ' "${id}/${lang}" >&2
  printf '%s\n' "${error_msg}" >&2
  # TODO: does not exit script if used in a function
  if [ -n "${error_exit_code}" ];then
    exit "${error_exit_code}"
  else
    exit 1
  fi
}
