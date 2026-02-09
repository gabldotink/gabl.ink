# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

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

    for t in ascii filename html id text; do
      eval "${set_var_l10n_name}_${t}"'="$(jq -r --arg o "${o}" --arg t "${t}" -- ".${set_var_l10n_property}"'"'"'.[$o].[$t]'"'"' "${set_var_l10n_source}")"' >/dev/null 2>&1
    done

    # TODO: Allow filename to populate ascii if applicable
    if test_null "${set_var_l10n_name}_filename";then
      unset "${set_var_l10n_name}_filename"
    fi

    if ! test_null "${set_var_l10n_name}_id";then
      unset "${set_var_l10n_name}_ascii" "${set_var_l10n_name}_filename" "${set_var_l10n_name}_html" "${set_var_l10n_name}_text"
      break
    fi

    unset "${set_var_l10n_name}_id"

    if test_null "${set_var_l10n_name}_text";then
      if ! test_null "${set_var_l10n_name}_ascii";then
        eval "${set_var_l10n_name}"'_text="${'"${set_var_l10n_name}"'_ascii}"'
      else
        unset "${set_var_l10n_name}_ascii" "${set_var_l10n_name}_text"
      fi
    fi

    ! test_null "${set_var_l10n_name}_html" &&
      break
    
    if [ -n "$(eval 'printf "%s" "${'"${set_var_l10n_name}"'_text}"')" ];then
      eval "${set_var_l10n_name}"'_html="${'"${set_var_l10n_name}"'_text}"'
      break
    fi

    unset "${set_var_l10n_name}_ascii"
  done
}
