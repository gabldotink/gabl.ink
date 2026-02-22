# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

unset_var_l10n(){
  unset_var_l10n_name="$1"
  unset "${unset_var_l10n_name}_ascii" "${unset_var_l10n_name}_filename" "${unset_var_l10n_name}_html" "${unset_var_l10n_name}_id" "${unset_var_l10n_name}_printf" "${unset_var_l10n_name}_text"
}
