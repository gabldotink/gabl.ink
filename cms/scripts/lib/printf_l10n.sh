# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

printf_l10n(){
  printf_l10n_id="$1"
  set_var_l10n printf_l10n_msg "\"${printf_l10n_id}\"" "${dict}/string.json"
  shift
  # We want to have formatting in this string
  # shellcheck disable=2059
  printf "${printf_l10n_msg_printf}" "$@"
}
