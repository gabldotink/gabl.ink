# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

warning(){
  warning_msg="$1"
  warning_exit_code="$2"
  printf 'warning: ' >&2
  [ -n "${id}" ] &&
    printf '%s: ' "${id}/${lang}" >&2
  printf '%s\n' "${warning_msg}" >&2
  # TODO: warning_warned is not globally set
  warning_warned=true
  # TODO: does not exit script if used in a function
  [ "${config_exit_on_warning}" = true ] &&
    if [ -n "${warning_exit_code}" ];then
      exit "${warning_exit_code}"
    else
      exit 1
    fi
}
