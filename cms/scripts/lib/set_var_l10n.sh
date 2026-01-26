# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ../build.sh only.

set_var_l10n(){
  set_var_l10n_name="$1"
  # shellcheck disable=2034
  set_var_l10n_property="$2"
  # shellcheck disable=2034
  set_var_l10n_source="$3"

  # TODO: Allow using values from other regions (e.g. en-GB for en-US)
  for o in "${lang}" "${lang_l}" mul "${lang_default}" e;do
    if [ "${o}" = e ];then
      error 'There is no suitable value for a variable'
      break
    fi

    for t in text html id; do
      eval "${set_var_l10n_name}_${t}"'="$(jq -r --arg o "${o}" --arg t "${t}" -- ".${set_var_l10n_property}"'"'"'.[$o].[$t]'"'"' "${set_var_l10n_source}")"' >/dev/null 2>&1
    done

    # This language has an id value; unset other values and end the loop
    if ! test_null "${set_var_l10n_name}_id";then
      unset "${set_var_l10n_name}_text" "${set_var_l10n_name}_html"
      break
    fi

    # This language has no id value; unset it
    unset "${set_var_l10n_name}_id"

    # This language has an html value
    if ! test_null "${set_var_l10n_name}_html";then
      # This language has no text value; unset it
      test_null "${set_var_l10n_name}_text" &&
        unset "${set_var_l10n_name}_text"
      # End the loop
      break
    fi
    
    # This language only has a text value
    if ! test_null "${set_var_l10n_name}_text";then
      # Set the html value to it, and end the loop
      eval "${set_var_l10n_name}"'_html="${'"${set_var_l10n_name}"'_text}"'
      break
    fi

    # This language has no value; unset text and html and continue to the next
    unset "${set_var_l10n_name}_text" "${set_var_l10n_name}_html"
  done
}
