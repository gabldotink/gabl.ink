# shellcheck shell=sh
# SPDX-License-Identifier: CC0-1.0

unset_var_l10n(){
  unset -- "$1_equal" "$1_html" "$1_id" "$1_printf" "$1_text"
}
