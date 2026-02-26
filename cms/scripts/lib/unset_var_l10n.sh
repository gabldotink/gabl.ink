# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

unset_var_l10n(){
  unset "$1_ascii" "$1_filename" "$1_html" "$1_id" "$1_printf" "$1_text"
}
